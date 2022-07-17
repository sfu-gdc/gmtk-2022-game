extends RigidBody

const DISH_LAYER := 1

onready var level := $"/root".get_child($"/root".get_child_count() - 1)

var number : int setget set_number

func set_number(value: int):
	number = value
	$DishLabel.text = str(number)

func _init():
	var mesh = MeshInstance.new()
	mesh.name = "MeshInstance"
	mesh.mesh = CubeMesh.new()
	mesh.mesh.size = Vector3(1.2,1.2,1.2)
	mesh.mesh.material = SpatialMaterial.new()
	
	mesh.mesh.material.albedo_texture = preload("res://art/fulldie1.png")
	
	mesh.mesh.material.uv1_scale = Vector3(1, 1, 1)
	add_child(mesh)
	mesh.translation += 0.75 * Vector3.UP

func pickup(player: KinematicBody) -> RigidBody:
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

func place(player: KinematicBody) -> bool:
	
	var save_transform := global_transform
	if self in player.get_children():
		player.remove_child(self)
		level.add_child(self)
		global_transform = save_transform
		global_transform.origin = (global_transform.origin - 2.0 * player.global_transform.basis.z)
	else:
		global_transform = save_transform
		global_transform.origin = global_transform.origin.snapped(Vector3(2.0, 2.0, 2.0))
	mode = RigidBody.MODE_CHARACTER
	collision_layer = DISH_LAYER
	collision_mask = DISH_LAYER

	return true