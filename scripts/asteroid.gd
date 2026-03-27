extends RigidBody2D
class_name Asteroid

signal hit

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var break_explosion: GPUParticles2D = $BreakExplosion

var size : int = 1
var previous_vel : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity_scale = 0
	set_size(randi_range(1,4))
	mass = pow(size, 3) * randf_range(0.8, 1.2)
	
	apply_impulse(Vector2(randf_range(-100, 100),randf_range(-100, 100)))
	angular_velocity = randf_range((-2 * PI), (2 * PI))
	
	previous_vel = linear_velocity
	
func set_size(s : int) -> void:
	#var s_scale = s / size
	#collision_shape_2d.apply_scale(Vector2(s_scale, s_scale))
	#sprite_2d.apply_scale(Vector2(s_scale, s_scale))
	size = s
	collision_shape_2d.scale = Vector2(s, s)
	sprite_2d.scale = Vector2(s, s)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass#bound()
	
func _physics_process(_delta: float) -> void:
	previous_vel = linear_velocity

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

func _on_hit() -> void:
	break_explosion.scale = Vector2(size, size)
	break_explosion.restart()
	
	if is_instance_valid(get_tree().get_first_node_in_group("Ship")):
		get_tree().get_first_node_in_group("Ship").emit_signal("got_points", 50 - (10 * size))
	
	if size > 1:
		var container = self.get_parent()
		var asteroid = load("res://scenes/asteroid.tscn")
		var instance = asteroid.instantiate()
		var mass_ratio = pow(float(size) / (size - 1), 3)
		
		container.add_child(instance)
		instance.mass = mass / mass_ratio
		instance.set_size(size - 1)
		instance.linear_velocity = linear_velocity.rotated(PI / 4) * 1.5
		instance.global_position = global_position + (instance.linear_velocity.normalized() * size)
		instance.angular_velocity = angular_velocity * 1.5
		
		set_size(size - 1)
		linear_velocity = linear_velocity.rotated(-PI / 4) * 1.5
	else:
		sprite_2d.visible = false
		collision_shape_2d.set_deferred("disabled", true)
		await break_explosion.finished
		queue_free()
