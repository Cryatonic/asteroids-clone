extends Control
class_name HUD

@export var score_amount : Label
@export var health_amount : Label

var score_tween : Tween = create_tween()
var pl_score : int = 0

var health_size_tween : Tween = create_tween()
var health_jiggle_tween : Tween = create_tween()

func _process(_delta: float) -> void:
	if score_tween:
		score_amount.text = str(pl_score)

#Sets the HUD's score label to the player's score.
func update_hud_labels(score : int, points : int, health : int):
	update_hud_score(score, points)
	update_hud_health(health)
	
func update_hud_health(health : int):
	health_amount.text = str(health)
	
	reset_tween(health_size_tween)
	health_size_tween.tween_property(health_amount, "scale", Vector2(1.5, 1.5), 0.25)
	health_size_tween.tween_property(health_amount, "scale", Vector2.ONE, 0.5)
	
	reset_tween(health_jiggle_tween)
	health_jiggle_tween.tween_property(health_amount, "rotation", PI / 18, 0.15)
	health_jiggle_tween.tween_property(health_amount, "rotation", -PI / 18, 0.15)
	health_jiggle_tween.tween_property(health_amount, "rotation", PI / 18, 0.15)
	health_jiggle_tween.tween_property(health_amount, "rotation", -PI / 18, 0.15)
	health_jiggle_tween.tween_property(health_amount, "rotation", 0, 0.15)
	
func update_hud_score(score : int, points : int):
	reset_tween(score_tween)
	score_tween.tween_property(self, "pl_score", score+points, 0.5)
	
func reset_tween(tween : Tween) -> void:
	match tween:
		score_tween:
			if score_tween:
				score_tween.kill()
			score_tween = create_tween()
		health_size_tween:
			if health_size_tween:
				health_size_tween.kill()
			health_size_tween = create_tween()
		health_jiggle_tween:
			if health_jiggle_tween:
				health_jiggle_tween.kill()
			health_jiggle_tween = create_tween()
