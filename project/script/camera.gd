extends Node

func _process(delta):
	if Input.is_action_pressed("up"):
		self.translation.z -= 1
	if Input.is_action_pressed("down"):
		self.translation.z += 1
	if Input.is_action_pressed("left"):
		self.translation.x -= 1
	if Input.is_action_pressed("right"):
		self.translation.x += 1
	if Input.is_action_pressed("vertical_up"):
		self.translation.y -= 1
	if Input.is_action_pressed("vertical_down"):
		self.translation.y += 1
