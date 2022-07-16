extends Position3D

onready var trash := $"/root".get_child(0).find_node("Trash")

func rotate_garbage():
	look_at(trash.global_transform.origin, Vector3.UP)
	rotation.x = 0.0
	rotation.z = 0.0
