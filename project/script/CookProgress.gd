extends ProgressBar

onready var UI_position = get_parent().get_node("UIPosition")
onready var styleBox = get("custom_styles/fg")
onready var pot = get_parent()

onready var BURN_FRACTION : float = pot.BURN_FRACTION

func _process(_delta):
	var fraction_to_burn := clamp(range_lerp(pot.cooking_time, max_value, BURN_FRACTION * max_value, 0.0, 1.0), 0.0, 1.0)
	
	if value == 0.0:
		visible = false
	else:
		visible = true
		styleBox.bg_color = Color(fraction_to_burn, 
									1.0 - fraction_to_burn, 
									0.0)
	
	var pot_screen_position := get_viewport().get_camera().unproject_position(UI_position.global_transform.origin)
	var screen_size : Vector2 = get_viewport().get_visible_rect().size
	var pot_screen_fraction := Vector2(pot_screen_position.x / screen_size.x, pot_screen_position.y / screen_size.y)
	
	anchor_left = pot_screen_fraction.x - 0.022 * (1.0 + fraction_to_burn)
	anchor_right = pot_screen_fraction.x + 0.022 * (1.0 + fraction_to_burn)
	anchor_top = pot_screen_fraction.y - 0.0555 + 0.0005 * (1.0 + fraction_to_burn)
	anchor_bottom = pot_screen_fraction.y - 0.0555 - 0.0005 * (1.0 + fraction_to_burn)
