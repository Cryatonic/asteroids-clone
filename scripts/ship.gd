extends RigidBody2D
class_name Ship

#const TORQUE_RADIUS = 0.8496
@onready var spin_damper: Timer = $SpinDamper
@onready var shoot_cooldown_timer: Timer = $ShootCooldown
signal hit
signal got_points
var bullet_scene = preload("res://scenes/bullet.tscn")

var health : int = 3
var hull_strength : float = 50000.0 #Joules withstood

var score : int = 0

var thrust_power : int = 3750 #Force(Newtons)
var thrust_limit : int = 250 #pixels/sec
@onready var previous_vel : Vector2 = linear_velocity

var side_thrust_power : int = 4000 #Force(Newtons)
var spin_limit : float = 2 * PI #Radians/sec

var thrusting : bool = false
var side_thrusting = [false, 0] #thrusting?; -1 = left thrust/turn, 1 = right
var dampeners_on : bool = false
var braking : bool = false
var invuln = [false, 0, 0.75] #invulnerable?; time invulnerable; max time invulnerable in seconds
var shoot_cooldown = [false, 0.2] #can shoot; shoot cooldown time in seconds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if invuln[0]:
		invulnerable(_delta)
	
func _physics_process(_delta: float) -> void:
	movement_controls(_delta)
	if get_contact_count() > 0:
		var bodies_hit = get_colliding_bodies()
		for body in bodies_hit:
			hit.emit(body, _delta)
	previous_vel = linear_velocity

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("thrust"):
		thrusting = true
	elif Input.is_action_just_released("thrust"):
		thrusting = false
	
	if Input.is_action_just_pressed("left_turn") || Input.is_action_just_pressed("right_turn"):
		side_thrusting[0] = true
		if _event.is_action("left_turn"):
			side_thrusting[1] = -1
		else:
			side_thrusting[1] = 1
	elif !Input.is_action_pressed("left_turn") && !Input.is_action_pressed("right_turn") && side_thrusting[0]:
		side_thrusting[0] = false
		side_thrusting[1] = 0
		if angular_velocity < spin_limit * 1.05:
			activate_dampeners()
	if Input.is_action_just_pressed("brake"):
		braking = true
	elif Input.is_action_just_released("brake"):
		braking = false
		stop_straglers()
		
	if Input.is_action_just_pressed("shoot"):
		if not shoot_cooldown[0]:
			shoot()
			shoot_cooldown_timer.start(shoot_cooldown[1])
			shoot_cooldown[0] = true
		
func movement_controls(_delta : float) -> void:
	if thrusting:
		var ship_angle = rotation - (PI / 2)
		var desired_vector : Vector2 = Vector2(cos(ship_angle), sin(ship_angle)) * thrust_limit
		thrust(desired_vector, _delta)
	
	if side_thrusting[0]:
		var desired_ang_vel = spin_limit * side_thrusting[1]
		side_thrust(desired_ang_vel)
			
	if braking:
		if linear_velocity != Vector2.ZERO:
			thrust(Vector2.ZERO, _delta)
		if angular_velocity != 0:
			side_thrust(0)
		
		stop_straglers()

func thrust(desired_vector : Vector2, _delta : float) -> void:
	var needed_vector : Vector2 = desired_vector - linear_velocity
	
	self.apply_central_force(needed_vector.normalized() * thrust_power)
func side_thrust(desired_ang_vel : float) -> void:
	var needed_ang_vel = desired_ang_vel - angular_velocity
		
	if side_thrusting[1] == 0:
		apply_torque(side_thrust_power * sign(needed_ang_vel))
	elif (sign(needed_ang_vel) == side_thrusting[1]) || (abs(angular_velocity) > spin_limit && (side_thrusting[1] != sign(angular_velocity))):
		apply_torque(side_thrust_power * side_thrusting[1])
func stop_straglers() -> void:
	if linear_velocity.length() < sqrt(2) * 5:
		linear_velocity = Vector2.ZERO
	if angular_velocity < 2 * PI * 0.10:
		angular_velocity = 0

func bound(bounding_box : Array) -> void:
	var out_of_bounds = [false, [0, 0]] #whether any are oob, [x-bound, y-bound]
	var x_pos = global_position.x
	var y_pos = global_position.y
	
	if x_pos < bounding_box[0] || x_pos > bounding_box[1]:
		out_of_bounds[0] = true
		if x_pos < bounding_box[0]:
			out_of_bounds[1][0] = 1
		else:
			out_of_bounds[1][0] = -1
			
	if y_pos < bounding_box[2] || y_pos > bounding_box[3]:
		out_of_bounds[0] = true
		if y_pos < bounding_box[2]:
			out_of_bounds[1][1] = 1
		else:
			out_of_bounds[1][1] = -1
			
	if out_of_bounds[0]:
		var x_bound = bounding_box[1] - bounding_box[0]
		var y_bound = bounding_box[3] - bounding_box[2]
		
		if out_of_bounds[1][0] != 0:
			global_position.x += x_bound * out_of_bounds[1][0]
		if out_of_bounds[1][1] != 0:
			global_position.y += y_bound * out_of_bounds[1][1]

func activate_dampeners() -> void:
	dampeners_on = true
	angular_damp = 2
	spin_damper.start(0.75)
	
func invulnerable(_delta : float) -> void:
	invuln[1] += _delta
	if invuln[1] > invuln[2]:
		invuln[0] = false
		invuln[1] = 0

func shoot() -> void:
	var bullet = bullet_scene.instantiate()
	get_parent().get_parent().get_node("BulletContainer").add_child(bullet)
	
	bullet.global_position = global_position
	bullet.rotation = rotation
	bullet.set_init_direction(rotation - (PI / 2))

func _on_spin_damper_timeout() -> void:
	if angular_damp != 0:
		dampeners_on = false
		angular_damp = 0
		if angular_velocity < spin_limit / 4:
			angular_velocity = 0


func _on_hit(impact_body, _delta : float) -> void:
	angular_damp = 0
	dampeners_on = false
	if not invuln[0]:
		if impact_body is RigidBody2D:
			var net_vel = impact_body.previous_vel - previous_vel
			var impact_ke : Vector2 = 0.5 * (impact_body.mass + mass) * net_vel * net_vel
			if (impact_ke).length() > hull_strength:
				health -= 1
				if health == 0:
					queue_free()
			invuln[0] = true


func _on_shoot_cooldown_timeout() -> void:
	shoot_cooldown[0] = false


func _on_got_points(points : int) -> void:
	score += points
