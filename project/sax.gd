extends Node

# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if Input.is_key_pressed(KEY_RIGHT):
		self.position.x += 8
	elif Input.is_key_pressed(KEY_LEFT):
		self.position.x -= 8

func _input(ev):
	pass
