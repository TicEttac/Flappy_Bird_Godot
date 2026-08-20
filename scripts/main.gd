extends Node

signal game_start

var pipe_color
var background : TextureRect
var game_started = false

@export var pipedoor_scene : PackedScene

@onready var pipedoor_speed = $Ground.ground_speed
#@onready var ground_y = $Ground/Sprite2D.position.y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_on_hud_new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") and not game_started:
		game_start.emit()
		game_started = true
		$PipeDoorTimer.start()

func _on_hud_new_game() -> void:
	var background_rnd = [true, false].pick_random()
	
	pipe_color = [true, false].pick_random()
	game_started = false

	if background_rnd:
		$BackgroundNight.is_choosen()
		$BackgroundDay.isnt_choosen()
	else:
		$BackgroundDay.is_choosen()
		$BackgroundNight.isnt_choosen()


func _on_bird_game_over() -> void:
	$PipeDoorTimer.stop()


func _on_pipe_door_timer_timeout() -> void:
	var ground_y = $Ground/CollisionShape2D.global_position.y
	var pipedoor = pipedoor_scene.instantiate()
	add_child(pipedoor)

	#pick pipe color
	if pipe_color:
		pipedoor.make_pipe_red()

	#connect signals to pipes
	$Bird.game_over.connect(pipedoor._on_game_over)
	$HUD.new_game.connect(pipedoor._on_new_game)
	
	#connect pipedoor score up to HUD score up
	pipedoor.score_up.connect($HUD._on_score_up)

	var low_bound = max(pipedoor.door_width + 120, ground_y - pipedoor.bottom_reach)
	var high_bound = min(ground_y, pipedoor.top_reach)

	pipedoor.position.x = 480
	pipedoor.position.y = randf_range(low_bound, high_bound)
	pipedoor.velocity = Vector2(pipedoor_speed * -1, 0)
