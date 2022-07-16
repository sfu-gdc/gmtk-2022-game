extends Spatial

export var player_is_near = false

var start_location = Vector3(translation)

func _ready():
	pass
	
func _process(_delta):
	if player_is_near:
		translation = start_location + Vector3.UP * 0.25
	else:
		translation = start_location
		
