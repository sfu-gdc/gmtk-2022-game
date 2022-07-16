extends RigidBody
class_name Die

onready var dice_pool := $"/root/Level1/DicePool"
onready var trash := $"/root".get_child(0).find_node("Trash")

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
	remove_from_group("pickup")
	var save_transform := global_transform
	player.remove_child(self)
	dice_pool.add_child(self)
	global_transform = save_transform
	
	var yeet := Tween.new()
	add_child(yeet)
# warning-ignore:return_value_discarded
	yeet.interpolate_property(self, "global_transform:origin", null, trash.global_transform.origin, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
# warning-ignore:return_value_discarded
	yeet.start()
	yield(yeet, "tween_completed")
	queue_free()

func pot(player: KinematicBody, dump_pot: Spatial):
	player.held_object = null
	remove_from_group("pickup")
	var save_transform := global_transform
	player.remove_child(self)
	dice_pool.add_child(self)
	global_transform = save_transform
	
	var yeet := Tween.new()
	add_child(yeet)
# warning-ignore:return_value_discarded
	yeet.interpolate_property(self, "global_transform:origin", null, dump_pot.global_transform.origin, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
# warning-ignore:return_value_discarded
	yeet.start()
	yield(yeet, "tween_completed")
	queue_free()
