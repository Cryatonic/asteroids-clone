extends Control
class_name HUD

@export var score_amount : Label
@export var health_amount : Label

#Sets the HUD's score label to the player's score.
func update_hud_labels(score : int, health : int):
	score_amount.text = str(score)
	health_amount.text = str(health)
	
func update_hud_health(health : int):
	health_amount.text = str(health)
	
func update_hud_score(score : int):
	score_amount.text = str(score)
