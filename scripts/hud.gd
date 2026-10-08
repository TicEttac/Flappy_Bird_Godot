extends CanvasLayer

#TODO :	change HighScoreManager to Logs
#		finish _on_leaderboard_pressed()

signal new_game

@onready var button_normal = load("res://assets/button_play_normal.png")
@onready var button_pressed = load("res://assets/button_play_pressed.png")

@onready var leaderboard_normal = load("res://assets/button_score_normal.png")
@onready var leaderboard_pressed = load("res://assets/button_score_pressed.png")

@onready var die_sound = preload("res://assets/sounds/sfx_die.wav")
@onready var point_sound = preload("res://assets/sounds/sfx_point.wav")

@export var score : int
var high_score: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ScoreAudioPlayer.stream = point_sound
	$DeathAudioPlayer.stream = die_sound
	score = 0
	$ScoreLabel.text = str(score)
	$GameOver.hide()
	$ReplayButton.hide()
	$Leaderboard.hide()
	high_score = SaveManager.high_score


func _on_main_game_start() -> void:
	$GetReady.hide()
	$ScoreLabel.show()
	$ReplayButton.hide()
	$Leaderboard.hide()
	$GameOver.hide()


func _on_bird_game_over() -> void:
	SaveManager.save_high_score(score)
	$HighScorePannel._display(score)
	$GameOver.show()
	$ReplayButton.texture = button_normal
	$Leaderboard.texture = leaderboard_normal
	$ReplayButton.show()
	$Leaderboard.show()
	Logs.end_game(score)
	$DeathAudioPlayer.play()



func _on_replay_button_pressed() -> void:
	score = 0
	$ScoreLabel.text = str(score)
	$ScoreAudioPlayer.stream = point_sound
	$HighScorePannel._hide()
	$GameOver.hide()
	$ReplayButton.hide()
	$Leaderboard.hide()
	$GetReady.show()
	new_game.emit()
	Logs.start_game()

func _on_score_up():
	score += 1
	$ScoreLabel.text = str(score)
	$ScoreAudioPlayer.play()
	Logs.pipe_passed()


func _on_button_button_down() -> void:
	$ReplayButton.texture = button_pressed

func _on_button_leaderboard_down() -> void:
	$Leaderboard.texture = leaderboard_pressed

func _on_leaderboard_pressed() -> void:
	$HighScorePannel.hide()
	$ReplayButton.hide()
	$Leaderboard.hide()
	$LeaderboardManager.actualize()
	$LeaderboardManager.show()


func _on_leaderboard_manager_hide_leaderboard() -> void:
	$LeaderboardManager.hide()
	$ReplayButton.show()
	$HighScorePannel.show()
	$Leaderboard.show()
