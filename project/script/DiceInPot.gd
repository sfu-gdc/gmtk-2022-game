extends GridContainer

const DIE_UI := preload("res://prefabs/DieUI.tscn")

onready var UI_position = get_parent().get_node("UIPosition")

var DIE_TEXTURES := {}
var image_size := 20.0
var num_dice := 0

func _ready():
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	
	columns = 1
	margin_left = -image_size / 2.0
	margin_right = image_size / 2.0
# warning-ignore:integer_division
	margin_top = -image_size * float((num_dice + 1) / 2)
	margin_bottom = 0.0
	
	var texture_path := "res://art/dice/"
	var dir = Directory.new()
	dir.open(texture_path)
	dir.list_dir_begin()
	var paths_left := true
	while paths_left:
		var file_name = dir.get_next()
		if file_name == "":
			paths_left = false
		elif file_name.begins_with("die_") and file_name.ends_with(".png"):
			var die_number := int(file_name.trim_prefix("die_").trim_suffix(".png"))
			DIE_TEXTURES[die_number] = load(texture_path + file_name)
	dir.list_dir_end()

func _process(_delta):
	var pot_screen_position := get_viewport().get_camera().unproject_position(UI_position.global_transform.origin)
	var screen_size : Vector2 = get_viewport().get_visible_rect().size
	var pot_screen_fraction := Vector2(pot_screen_position.x / screen_size.x, pot_screen_position.y / screen_size.y)
	
	anchor_left = pot_screen_fraction.x
	anchor_right = pot_screen_fraction.x
	anchor_top = pot_screen_fraction.y
	anchor_bottom = pot_screen_fraction.y

func add_die(number: int):
	var new_die := DIE_UI.instance()
	new_die.texture = DIE_TEXTURES[number]
	add_child(new_die)
	num_dice += 1
	columns = int(min(2, num_dice))
	margin_left = -image_size * columns / 2.0
	margin_right = image_size * columns / 2.0
# warning-ignore:integer_division
	margin_top = -image_size * float((num_dice + 1) / 2)
	margin_bottom = 0.0

func clear_dice():
	for child in get_children():
		child.queue_free()
	num_dice = 0
	columns = 1
	margin_left = -image_size / 2.0
	margin_right = image_size / 2.0
# warning-ignore:integer_division
	margin_top = -image_size * float((num_dice + 1) / 2)
	margin_bottom = 0.0

func _on_viewport_size_changed():
	image_size = get_viewport().get_visible_rect().size.y / 30.0
	margin_left = -image_size * columns / 2.0
	margin_right = image_size * columns / 2.0
# warning-ignore:integer_division
	margin_top = -image_size * float((num_dice + 1) / 2) / 2.0
	margin_bottom = image_size * float((num_dice + 1) / 2) / 2.0
