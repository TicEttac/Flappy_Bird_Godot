extends CanvasLayer

signal new_game

@export var score : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0
	$ScoreLabel.text = str(score)
	$GameOver.hide()
	$ReplayButton.hide()


func _on_main_game_start() -> void:
	$GetReady.hide()
	$ScoreLabel.show()
	$ReplayButton.hide()
	$GameOver.hide()


func _on_bird_game_over() -> void:
	$GameOver.show()
	$ReplayButton.show()


func _on_replay_button_pressed() -> void:
	score = 0
	$ScoreLabel.text = str(score)

	$GameOver.hide()
	$ReplayButton.hide()
	$GetReady.show()
	new_game.emit()
	print("replay button pressed")

func _on_score_up():
	score += 1
	$ScoreLabel.text = str(score)
	print("score up")
	
