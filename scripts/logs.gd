extends Node

#logs.gd
#last modified : 01/09/2026
#Abstract : This file is a singletone used to store the ten lasts 
#games and the best game in a log file named games.json in files/
#folder. The file respect the following format.

#LOG FILE FORMAT :
#{
	#"pseudo":"~pseudo"
	#"best_game":
	#{
		#"id": "~id",
		#"pipe_passed": ["~timestamp", "~timestamp", "~timestamp", "~timestamp", "~timestamp"],
		#"death": "~timestamp",
		#"score": "~score"
	#},
	#"games":[
	#{
		#"id": "~id",
		#"pipe_passed": ["~timestamp", "~timestamp", "~timestamp", "~timestamp", "~timestamp"],
		#"death": "~timestamp",
		#"score": "~score"
	#},
	#{
		#"id": "~id",
		#"pipe_passed": ["~timestamp", "~timestamp", "~timestamp", "~timestamp", "~timestamp"],
		#"death": "~timestamp",
		#"score": "~score"
	#}]
#}

enum returns {DONE, ERROR, EXISTING}

const FILE_BASE = {"best_game":{},"games":[]}
const CLEAN_GAME = {"id":0, "pipe_passed":[], "death":0, "score":0}
const FILENAME = "games"

var Leaderboard: Dictionary = {}
var current_game: Dictionary

func _ready():
	current_game = CLEAN_GAME.duplicate(true)
	create_file(FILENAME)

##Transform filename into path/filename.json
func filename_to_path(filename: String) -> String:
	return ("user://"+ filename + ".json")

##Test function used to print file content
func _print_file(filename: String):
	var file = FileAccess.open(filename_to_path(filename), FileAccess.READ)
	var file_txt = file.get_as_text()
	print("file content : " + file_txt)

##Create and format file as shown in LOG FILE FORMAT or as filebase if provided
func create_file(filename: String = FILENAME, filebase: Dictionary = FILE_BASE):
	if FileAccess.file_exists("user://" + filename + ".json"):
		return returns.EXISTING
	var file = FileAccess.open(filename_to_path(filename), FileAccess.WRITE)
	if file:
		var file_base = JSON.stringify(filebase)
		file.store_string(file_base)
		file.close()
		return returns.DONE
	return returns.ERROR

##Remove old games to keep only the 10 lasts
func _clean_savefile(filename: String):
	var file = FileAccess.open(filename_to_path(filename), FileAccess.READ_WRITE)
	if !file:
		return returns.ERROR
	var file_txt = file.get_as_text()
	file.close()
	var json_file = JSON.parse_string(file_txt)
	var game_array: Array = json_file["games"]
	if game_array.size() < 10:
		return returns.DONE
	while game_array.size() >= 10 :
		game_array.remove_at(0)

	#Reopen in WRITE mode to clean file
	file = FileAccess.open(filename_to_path(filename), FileAccess.WRITE)
	if !file:
		return returns.ERROR
	json_file["games"] = game_array
	file_txt = JSON.stringify(json_file)
	file.store_string(file_txt)
	file.close()
	return returns.DONE

##Setup current_game which represent the current game
func start_game():
	var id: int = 0
	var file = FileAccess.open(filename_to_path(FILENAME), FileAccess.READ_WRITE)
	var file_content = file.get_as_text()
	file.close()
	
	var json_file = JSON.parse_string(file_content)
	var game_array = json_file["games"]
	if game_array.size() != 0:
		id = game_array[-1]["id"] + 1
	current_game = CLEAN_GAME.duplicate(true)
	current_game["id"] = id

#Add pipe passed timestamp to the current game
func pipe_passed():
	var timestamp = Time.get_unix_time_from_system()
	current_game["pipe_passed"].append(timestamp)

#Save current game into log file
func _save_game(filename: String):
	if !FileAccess.file_exists("user://" + filename + ".json"):
		create_file(filename)
	var cleaned = _clean_savefile(filename)
	var file = FileAccess.open(filename_to_path(filename), FileAccess.READ_WRITE)
	if cleaned != returns.DONE or !file:
		return returns.ERROR

	var file_content = file.get_as_text()
	var json_file = JSON.parse_string(file_content)
	
	#Save best game
	if json_file["best_game"].is_empty():
		json_file["best_game"] = current_game
	else:
		var best_score: int = 0
		for game in json_file["games"]:
			if game["score"] > best_score:
				best_score = game["score"]
		if current_game["score"] > best_score:
			json_file["best_game"] = current_game
	
	#Store current game in log file
	var game_array = json_file["games"]
	game_array.append(current_game)
	json_file["games"] = game_array
	
	var updated_file = JSON.stringify(json_file)
	file.store_string(updated_file)
	file.close()
	return returns.DONE

#Check if current game is valid and, if so, save it
func end_game(score: int):
	if current_game["pipe_passed"].size() != score:
		current_game = CLEAN_GAME.duplicate(true)
		return returns.ERROR
	current_game["score"] = score
	current_game["death"] = Time.get_unix_time_from_system()
	_save_game(FILENAME)

func get_best_game():
	var return_dict: Dictionary
	var file = FileAccess.open(filename_to_path(FILENAME), FileAccess.READ)
	if !file:
		return returns.ERROR
	var file_txt = file.get_as_text()
	file.close()
	var json_file = JSON.parse_string(file_txt)
	if !json_file.has("best_game"):
		return returns.ERROR
	return_dict = json_file["best_game"]
	var pseudo = get_pseudo()
	return_dict["pseudo"] = pseudo
	return return_dict
	
func set_pseudo(pseudo: String):
	var file = FileAccess.open(filename_to_path(FILENAME), FileAccess.READ)
	if !file or !pseudo:
		return returns.ERROR
	var file_txt = file.get_as_text()
	file.close()
	var json_file = JSON.parse_string(file_txt)
	if json_file.has("pseudo"):
		return returns.EXISTING
	json_file["pseudo"] = pseudo
	var write_file = FileAccess.open(filename_to_path(FILENAME), FileAccess.WRITE)
	if !write_file:
		return returns.ERROR
	var new_string_file = JSON.stringify(json_file)
	write_file.store_string(new_string_file)
	write_file.close()
	return returns.DONE
	
func get_pseudo():
	var file = FileAccess.open(filename_to_path(FILENAME), FileAccess.READ)
	if !file:
		return returns.ERROR
	var file_txt = file.get_as_text()
	var json_file = JSON.parse_string(file_txt)
	file.close()
	if json_file.has("pseudo"):
		return json_file["pseudo"]
	return ""


##Basic true or false on filename existence
func file_exist(filename: String) ->  bool:
	var filepath = filename_to_path(filename)
	if FileAccess.file_exists(filepath):
		return true
	return false


##Get JSON Dictionary from filename file content
func get_json_content(filename: String) -> Dictionary:
	if Leaderboard != {}:
		return Leaderboard
	if file_exist(filename):
		var file = FileAccess.open(filename_to_path(FILENAME), FileAccess.READ)
		if file:
			var file_txt = file.get_as_text()
			var json_file = JSON.parse_string(file_txt)
			Leaderboard = json_file
			file.close()
	return Leaderboard


func update_file(filename: String, json_data: Dictionary):
	if !file_exist(filename):
		return returns.ERROR
	var file = FileAccess.open(filename_to_path(filename), FileAccess.WRITE)
	if !file:
		return returns.ERROR
	Leaderboard = json_data
	var updated_file = JSON.stringify(json_data)
	file.store_string(updated_file)
	file.close()
	return returns.DONE
