extends Label

onready var pot = $".."
onready var UI_position = get_parent().get_node("UIPosition")

func _process(_delta):
	text = str(pot.sum)
	visible = pot.sum != 0
	
	var pot_screen_position := get_viewport().get_camera().unproject_position(UI_position.global_transform.origin)
	var screen_size : Vector2 = get_viewport().get_visible_rect().size
	var pot_screen_fraction := Vector2(pot_screen_position.x / screen_size.x, pot_screen_position.y / screen_size.y)
	
	anchor_left = pot_screen_fraction.x
	anchor_right = pot_screen_fraction.x
	anchor_top = pot_screen_fraction.y - 0.085
	anchor_bottom = pot_screen_fraction.y - 0.085
