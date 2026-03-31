extends Control
class_name TitleScreen

var spin_time : float = 4.0
@onready var ship_sprite: Sprite2D = $ShipSprite
@onready var asteroid_sprite: Sprite2D = $AsteroidSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	ship_sprite.rotate(2 * PI / spin_time * _delta)
	asteroid_sprite.rotate(2 * PI / spin_time * _delta)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://ba43v52yoyorm")


func _on_controls_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://xibixcnpg7pq")
