extends Area2D
class_name Bullet

var velocity : Vector2
var bullet_speed : int = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	move(_delta)

func move(_delta : float):
	global_position += velocity * _delta

func set_init_direction(angle : float):
	velocity = Vector2(cos(angle), sin(angle)) * bullet_speed

func bound(bounding_box) -> void:
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

func die() -> void:
	queue_free()
func _on_life_timer_timeout() -> void:
	die()


func _on_body_entered(body: Node2D) -> void:
	if body is Asteroid:
		body.hit.emit()
		die()
