extends Label

onready var label_pos := $"../LabelPosition"

func _process(_delta):
	var screen_position := get_viewport().get_camera().unproject_position(label_pos.global_transform.origin)
	var screen_size : Vector2 = get_viewport().get_visible_rect().size
	var screen_fraction := Vector2(screen_position.x / screen_size.x, screen_position.y / screen_size.y)
	
	anchor_left = screen_fraction.x
	anchor_right = screen_fraction.x
	anchor_top = screen_fraction.y
	anchor_bottom = screen_fraction.y
