extends Node2D

var timer = 0.0

const speed = 300
onready var internal_position = Vector2(self.position)
onready var base_y = internal_position.y

func _ready():
	pass

func _process(delta):
	internal_position.x += delta * speed
	internal_position.y = base_y + sin(internal_position.x / PI / 10) * 30
	self.position.x = round(internal_position.x / 10) * 10
	self.position.y = round(internal_position.y / 10) * 10
	
	timer += delta
	
	if timer > 1.6:
		self.modulate.a -= 0.08
		
	if self.modulate.a == 0:
		get_parent().remove_child(self)
