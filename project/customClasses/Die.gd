extends RigidBody
class_name Die

onready var dice_pool := $"/root/Level1/DicePool"

const DIE_LAYER := 1


var number : int


func _init():
	add_to_group("pickup")

func pickup(player: KinematicBody) -> Die:
	# Attach to player and disable collisions
	var save_transform := global_transform
	get_parent().remove_child(self)
	mode = RigidBody.MODE_STATIC
	collision_layer = 0
	collision_mask = 0
	player.add_child(self)
	global_transform = save_transform
	transform.origin = player.pickup_position
	
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

func garbage(player: KinematicBody):
	player.held_object = null
	queue_free()
