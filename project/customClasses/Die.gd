extends RigidBody
class_name Die

export var pickup_height := 1.5

onready var dice_pool := $"/root/Level1/DicePool"

const DIE_LAYER := 1


var number : int

func pickup(player: KinematicBody) -> Die:
	# Attach to player and disable collisions
	var save_transform := global_transform
	get_parent().remove_child(self)
	mode = RigidBody.MODE_STATIC
	collision_layer = 0
	collision_mask = 0
	player.add_child(self)
	global_transform = save_transform
	global_transform.origin.y = pickup_height
	
	return self

func place():
	var player : KinematicBody = get_parent()
	var save_transform := global_transform
	player.remove_child(self)
	dice_pool.add_child(self)
	global_transform = save_transform
	mode = RigidBody.MODE_RIGID
	collision_layer = DIE_LAYER
	collision_mask = DIE_LAYER
