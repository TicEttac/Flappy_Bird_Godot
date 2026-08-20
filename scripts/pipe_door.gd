extends Node2D

signal score_up

var door_width
var top_reach
var bottom_reach

var velocity = Vector2.ZERO
var mobility = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var door_rect = $ScoreZone/CollisionShape2D.shape.get_rect()
	door_width = door_rect.size.y + abs(door_rect.position.y)
	
	var pipe_shape = $PipeUp/CollisionShape2D.shape as RectangleShape2D
	var pipe_half_height = (pipe_shape.size.y * $PipeUp.scale.y) / 2.0

	top_reach = abs($PipeUp.position.y) + pipe_half_height
	bottom_reach = $PipeDown.position.y + pipe_half_height 

func make_pipe_red():
	$PipeUp/GreenSprite.hide()
	$PipeDown/GreenSprite.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if mobility:
		position.x += velocity.x * delta
		position.y += velocity.y * delta

	if position.x <= 0:
		queue_free()

func _on_game_over():
	mobility = false
	
func _on_new_game():
	queue_free()

func _on_score_zone_body_exited(_body: Node2D) -> void:
	#up the score only if game is running
	if mobility:
		score_up.emit()
