extends Node

const SAVE_PATH = "user://score.cfg"
var high_score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_high_score()


func load_high_score() -> void:
	var config_file = ConfigFile.new()
	var err = config_file.load(SAVE_PATH)
	if err == OK:
		high_score = config_file.get_value('scores', 'high_score', 0)
	else:
		high_score = 0


func save_high_score(score: int) -> void:
	if score > high_score:
		high_score = score
		var config_file = ConfigFile.new()
		config_file.set_value('scores', 'high_score', high_score)
		config_file.save(SAVE_PATH)
