extends CharacterBody2D

signal game_over

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var game_started = false
var game_await = true

func _ready() -> void:
	_on_hud_new_game()


func _physics_process(delta: float) -> void:
	#Await the start of the game
	if game_started:
		
		var collision = get_last_slide_collision()

		#handle game over
		if collision:
			var collider = collision.get_collider()
			print("collision with ", collider.name)
			game_over.emit()
			game_started = false
			print("game over")
			return

		# Handle jump
		if Input.is_action_just_pressed("jump"):
			jump()

	# Add the gravity.
	if not is_on_floor() and not game_await:
		velocity += get_gravity() * delta
	move_and_slide()


func jump():
	velocity.y = JUMP_VELOCITY
	$JumpTimer.start()
	rotation = 0
	if not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play()


#stop animation and rotate to the ground(TODO)
func _on_jump_timer_timeout() -> void:
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.frame = 1
	rotate(PI/2)


func _on_main_game_start() -> void:
	game_await = false
	game_started = true
	jump()


func _on_hud_new_game() -> void:
	game_await = true
	var bird_color = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = bird_color.pick_random()
	$AnimatedSprite2D.play()
	position.x = 150
	position.y = 360
	velocity = Vector2.ZERO
	rotation = 0
