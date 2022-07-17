extends Spatial

var player_is_near = [false, false]

var start_location = Vector3(translation)

func _ready():
	pass
	
func _process(_delta):
	if player_is_near[0] || player_is_near[1]:
		translation = start_location + Vector3.UP * 0.25
	else:
		translation = start_location
		
