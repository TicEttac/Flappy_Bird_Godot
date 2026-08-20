extends CanvasLayer

signal new_game

@onready var button_normal = load("res://assets/button_play_normal.png")
@onready var button_pressed = load("res://assets/button_play_pressed.png")

@export var score : int
var high_score: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0
	$ScoreLabel.text = str(score)
	$GameOver.hide()
	$ReplayButton.hide()
	high_score = SaveManager.high_score


func _on_main_game_start() -> void:
	$GetReady.hide()
	$ScoreLabel.show()
	$ReplayButton.hide()
	$GameOver.hide()


func _on_bird_game_over() -> void:
	SaveManager.save_high_score(score)
	$HighScorePannel._display(score)
	$GameOver.show()
	$ReplayButton.texture = button_normal
	$ReplayButton.show()



func _on_replay_button_pressed() -> void:
	score = 0
	$ScoreLabel.text = str(score)

	$HighScorePannel._hide()
	$GameOver.hide()
	$ReplayButton.hide()
	$GetReady.show()
	new_game.emit()
	print("replay button pressed")

func _on_score_up():
	score += 1
	$ScoreLabel.text = str(score)
	print("score up")


func _on_button_button_down() -> void:
	$ReplayButton.texture = button_pressed
