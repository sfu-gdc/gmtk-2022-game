extends CPUParticles2D

onready var UI = get_parent().get_node("DiceInPot")

func _process(_delta):
	var UI_screen_position : Vector2 = UI.rect_global_position
	
	position = UI_screen_position + 0.5 * UI.image_size * UI.size_multiplier * (Vector2.DOWN + Vector2.RIGHT)
