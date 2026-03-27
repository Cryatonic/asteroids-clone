extends Node

var game_window : Vector2i = DisplayServer.window_get_size()
var asteroid_count : int = 0
var asteroid_scene = preload("uid://daal6r1h66y8w")
var ship_scene = preload("uid://cmysf7mbefxp5")
var ship : Ship

var debug_mode : bool = false

@onready var hud: HUD = $HUD

var bounding_box = [-32, 1232, 32, 732] #min x, max x, min y, max y
@onready var spawn_timer: Timer = $SpawnTimer
@onready var cached_asteroids : Array

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	#cache_num_asteroids(50)
	
	print(cached_asteroids)
	spawn_ship(Vector2i(bounding_box[1] / 2, bounding_box[3] / 2))
	for x in range(0, 10):
		random_spawn_asteroid()

func _process(_delta: float) -> void:
	check_bounding()
	if is_instance_valid(ship):
		hud.update_hud_labels(ship.score, ship.health)
	else:
		hud.update_hud_health(0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn_asteroid"):
		var spawn_location = event.position
		spawn_asteroid(spawn_location)
		
	elif event.is_action_pressed("data"):
		print(asteroid_count)
		
	elif event.is_action_pressed("respawn") && get_node("ShipContainer").get_child_count() == 0 && debug_mode:
		spawn_ship(Vector2i(bounding_box[1] / 2, bounding_box[3] / 2))
	elif event.is_action_pressed("respawn"):
		restart()
		
	if Input.is_key_pressed(KEY_SHIFT) && Input.is_key_pressed(KEY_B) && Input.is_key_pressed(KEY_M):
		if not debug_mode:
			debug_mode = true
		else:
			debug_mode = false
		
func spawn_asteroid(spawn_location : Vector2i):
	var instance = asteroid_scene.instantiate()
	get_node("AsteroidContainer").add_child(instance)
	instance.global_position = spawn_location
	asteroid_count += 1

func random_spawn_asteroid():
	var spawn_location : Vector2i = Vector2i.ZERO
	
	var side = (randi_range(0,3)) #0 = left, 1 = right, 2 = top, 3 = bottom
	var spot = bounding_box[0] / 2
	
	if side == 0 || side == 1:
		if side == 0:
			spawn_location = Vector2i(spot, randi_range(bounding_box[2], bounding_box[3]))
		else:
			spawn_location = Vector2i(bounding_box[1] + spot, randi_range(bounding_box[2], bounding_box[3]))
	else:
		if side == 2:
			spawn_location = Vector2i(randi_range(bounding_box[0], bounding_box[1]), bounding_box[2] + spot)
		else:
			spawn_location = Vector2i(randi_range(bounding_box[0], bounding_box[1]), bounding_box[3] + spot)
			
	spawn_asteroid(spawn_location)
	
func restart() -> void:
	if get_node("AsteroidContainer").get_child_count() != 0:
		for each in get_node("AsteroidContainer").get_children():
			each.queue_free()
	if get_node("ShipContainer").get_child_count() != 0:
		for s in get_node("ShipContainer").get_children():
			s.queue_free()
		
	await get_tree().process_frame
	
	spawn_ship(Vector2i(bounding_box[1] / 2, bounding_box[3] / 2))
	for x in range(0, 10):
		random_spawn_asteroid()

func check_bounding() -> void:
	var asteroids = get_node("AsteroidContainer").get_children()
	for a in asteroids:
		a.bound(bounding_box)
	var ships = get_node("ShipContainer").get_children()
	for s in ships:
		s.bound(bounding_box)
	var bullets = get_node("BulletContainer").get_children()
	for bullet in bullets:
		bullet.bound(bounding_box)
		
func spawn_ship(spawn_location : Vector2i) -> void:
	for each in get_node("BulletContainer").get_children():
		each.die()
	
	ship = ship_scene.instantiate()
	get_node("ShipContainer").add_child(ship)
	ship.global_position = spawn_location
	hud.update_hud_labels(ship.score, ship.health)
	
func cache_num_asteroids(num_cached : int) -> void:
	if num_cached < 1:
		return
	
	var aster = asteroid_scene.instantiate()
	for num in range(0,num_cached):
		cached_asteroids.append(aster)
		if num < num_cached - 1:
			aster = asteroid_scene.instantiate()


func _on_spawn_timer_timeout() -> void:
	if get_node("AsteroidContainer").get_child_count() > 8 || asteroid_count < 50:
		random_spawn_asteroid()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		NOTIFICATION_WM_MOUSE_ENTER:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
