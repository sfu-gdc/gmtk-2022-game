extends Spatial

var pot_to_follow : RigidBody

func _process(_delta):
	global_transform = pot_to_follow.global_transform
