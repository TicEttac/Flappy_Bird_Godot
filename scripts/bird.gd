extends CharacterBody2D

signal game_over

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var game_started = false
var game_await = true

# --- Rotation ---
const MAX_FALL_ROTATION = deg_to_rad(90)   # nez vers le bas, chute max
const MAX_RISE_ROTATION = deg_to_rad(-30)  # nez vers le haut, au saut
const ROTATION_LERP_SPEED = 8.0            # + haut = transition + rapide
const FALL_SPEED_FOR_MAX_ROTATION = 600.0  # vitesse de chute donnant 90°


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
	
	if game_started == true:
		update_rotation(delta)


func update_rotation(delta: float) -> void:
	var target_rotation: float
	if velocity.y < 0:
		target_rotation = MAX_RISE_ROTATION
	else:
		var t = clamp(velocity.y / FALL_SPEED_FOR_MAX_ROTATION, 0.0, 1.0)
		target_rotation = lerp_angle(0.0, MAX_FALL_ROTATION, t)

	rotation = lerp_angle(rotation, target_rotation, ROTATION_LERP_SPEED * delta)


func jump():
	velocity.y = JUMP_VELOCITY
	$JumpTimer.start()
	if not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play()


func _on_jump_timer_timeout() -> void:
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.frame = 1


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
