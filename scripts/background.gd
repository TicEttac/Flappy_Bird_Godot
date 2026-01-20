extends Sprite2D
@export var ground_speed = 10

@onready var first_sprite = self
@onready var screen_size = get_viewport_rect().size
@onready var origin_point = first_sprite.position

var next_sprite
var tmp_sprite
var game_started = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	print("sprite frame")
	if game_started:
		#create a new ground sprite at the right of the existing one
		if next_sprite is not Sprite2D:
			next_sprite = first_sprite.duplicate()
			add_child(next_sprite)
			next_sprite.position.x = screen_size.x + first_sprite.position.x

		#handle ground movement
		first_sprite.position.x -= ground_speed * delta
		if next_sprite is Sprite2D:
			next_sprite.position.x -= ground_speed * delta

		#handle deletion of out-of-scope ground sprite by switching first and next sprite so it trigger
		# the creation next _process
		if first_sprite.position.x + screen_size.x / 2 <= 0:
			#line to test
			first_sprite.position = screen_size.x + first_sprite.position.x
			tmp_sprite = first_sprite
			first_sprite = next_sprite
			next_sprite = first_sprite
	else:
		pass

func _on_bird_game_over() -> void:
	game_started = false


func _on_hud_new_game() -> void:	
	"""first_sprite.position = origin_point
	if next_sprite:
			next_sprite.queue_free()"""
	game_started = true
