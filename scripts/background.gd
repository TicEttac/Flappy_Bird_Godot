extends TextureRect

var speed: float = 0.07
var scroll_offset: float = 0.0
var game_on: bool = true
var choosen: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if choosen == true and game_on == true:
		scroll_offset += speed * delta
		material.set_shader_parameter("scroll_offset", scroll_offset)


func _on_bird_game_over() -> void:
	game_on = false

func _on_hud_new_game() -> void:
	game_on = true

func is_choosen():
	choosen = true
	show()
	
func isnt_choosen():
	choosen = false
	hide()
