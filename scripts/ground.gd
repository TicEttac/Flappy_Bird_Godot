extends StaticBody2D

@onready var first_sprite = $Sprite2D
@onready var screen_size = get_viewport_rect().size
@onready var origin_point = $Sprite2D.position
@export var ground_speed = 100
var next_sprite
var game_started = true
const BASE_HEIGHT = 720.0


func _ready() -> void:
	var real_height = get_viewport_rect().size.y
	var offset = real_height - BASE_HEIGHT
	position.y += offset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
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
			first_sprite.queue_free()
			first_sprite = next_sprite
			next_sprite = 0
	else:
		pass

func _on_bird_game_over() -> void:
	game_started = false


func _on_hud_new_game() -> void:	
	"""first_sprite.position = origin_point
	if next_sprite:
			next_sprite.queue_free()"""
	game_started = true
