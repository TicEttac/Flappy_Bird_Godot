extends Control

signal hide_leaderboard

var leaderboard_url = "http://127.0.0.1:8000/leaderboard"
var post_score_url = "http://127.0.0.1:8000/score/"


@onready var leaderboard_case = load("res://scene/leaderboard_case.tscn")
# 9 cases with 2 px height between cases starting at 5,18

@onready var back_button_pressed = load("res://assets/button_back_pressed.png")
@onready var back_button_normal = load("res://assets/button_back_normal.png")
@onready var send_button_pressed = load("res://assets/button_send_pressed.png")
@onready var send_button_normal = load("res://assets/button_send_normal.png")
@onready var pseudo_button_pressed = load("res://assets/button_set_pressed.png")
@onready var pseudo_button_normal = load("res://assets/button_set_normal.png")

var Case_list: Array
var Best_score ##Dictionary or Logs.returns (enum)


func _ready() -> void:
	hide()
	$HTTPLeaderboard.request_completed.connect(_http_leaderboard_completed)
	$HTTPSend.request_completed.connect(_http_send_completed)

##Request leaderboard, reset button state and actualize best score
func actualize():
	$HTTPLeaderboard.request(leaderboard_url)
	$BackButton.texture = back_button_normal
	$ShareButton.texture = send_button_normal
	if Logs.get_pseudo() != "":
		$PseudoBox.hide()
	$ErrorLabel.text = ""
	Best_score = Logs.get_best_game()

##Delete all leaderboard cases
func _empty_cases():
	for case in Case_list:
		if is_instance_valid(case):
			case.queue_free()
	Case_list = []


##Create leaderboard_case node for each case on leaderboard.json.
##Do nothing if cases already exist. For a refresh call _empty_cases() first.
func display_leaderboard():
	if Case_list != []:
		return
	var leaderboard = {}
	if Logs.Leaderboard == {}:
		leaderboard = Logs.get_json_content("leaderboard")
	else:
		leaderboard = Logs.Leaderboard["data"]
	var list_size = 8
	var case_x = 240
	var case_y = 150
	if $PseudoBox.visible == true:
		list_size = 7
		case_y += 50
	for i in range(0, list_size):
		if i >= leaderboard.size():
			break
		var case_in_array = leaderboard[i]
		var case = leaderboard_case.instantiate()
		case.set_pseudo(case_in_array["pseudo"])
		case.set_score(case_in_array["score"])
		case.position = Vector2(case_x, case_y)
		case_y += 50
		Case_list.append(case)
		add_child(case)


##Return true if best is in leaderboard, false if not
func is_best_in_leaderboard()->bool:
	for case in Case_list:
		if case["pseudo"] == Best_score["pseudo"] and case["score"] == Best_score["score"]:
			return true
	return false

func _http_leaderboard_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	if response_code != 200:
		$ErrorLabel.text = "Error getting leaderboard : " + str(response_code)
		display_leaderboard()
		return
	var json_string = body.get_string_from_utf8()
	var json_data = JSON.parse_string(json_string)
	if Logs.file_exist("leaderboard"):
		var json_leaderboard = Logs.get_json_content("leaderboard")
		if json_leaderboard != {"data":json_data}:
			if Logs.update_file("leaderboard", {"data":json_data}) == Logs.returns.ERROR:
				$ErrorLabel.text = "Error updating leaderboard"
	else:
		Logs.create_file("leaderboard", {"data":json_data})
	display_leaderboard()


func _http_send_completed(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray):
	if response_code != 200:
		$ErrorLabel.text = "Error sending best score : " + str(response_code)
		return
	_empty_cases()
	actualize()
	display_leaderboard()

#--------------------------BUTTONS SIGNALS----------------------------

func _on_button_back_down() -> void:
	$BackButton.texture = back_button_pressed


func _on_button_back_pressed() -> void:
	hide_leaderboard.emit()


func _on_button_send_down() -> void:
	$ShareButton.texture = send_button_pressed


func _on_button_send_up() -> void:
	$ShareButton.texture = send_button_normal


func _on_button_send_pressed() -> void:
	if Best_score is not Dictionary and Best_score == Logs.returns.ERROR:
		$ErrorLabel.text = "Error loading best score"
		return
	if Logs.get_pseudo() == "":
		$ErrorLabel.text = "Please enter pseudo"
		return
	if is_best_in_leaderboard():
		$ErrorLabel.text = "Best score already registered"
		return
	var pipe_passed = Best_score["pipe_passed"]
	Best_score["key"] = float(Best_score["death"]) + float(pipe_passed[0]) / 3
	var body = JSON.stringify(Best_score)
	var headers = ["Content-Type: application/json"]
	$HTTPSend.request(post_score_url, headers, HTTPClient.METHOD_POST, body)


func _on_button_set_down() -> void:
	$PseudoBox/PseudoButton.texture = pseudo_button_pressed


func _on_button_set_pressed() -> void:
	if !$PseudoBox/LineEdit.text:
		return
	var pseudo = $PseudoBox/LineEdit.text
	if Logs.set_pseudo(pseudo) != Logs.returns.DONE:
		$ErrorLabel.text = "Error while setting pseudo"
		return
	$PseudoBox.hide()
	_empty_cases()
	display_leaderboard()
	print(Case_list)


func _on_button_set_up() -> void:
	$PseudoBox/PseudoButton.texture = pseudo_button_normal
