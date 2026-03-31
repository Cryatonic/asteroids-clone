extends Control
class_name HUD

@export var score_amount : Label
@export var health_amount : Label

var tween : Tween = create_tween()
var pl_score : int = 0

func _process(_delta: float) -> void:
	if tween:
		score_amount.text = str(pl_score)

#Sets the HUD's score label to the player's score.
func update_hud_labels(score : int, points : int, health : int):
	update_hud_score(score, points)
	update_hud_health(health)
	
func update_hud_health(health : int):
	health_amount.text = str(health)
	
func update_hud_score(score : int, points : int):
	reset_tween()
	tween.tween_property(self, "pl_score", score+points, 0.5)
	
	#score_amount.text = str(pl_score)
	
func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
