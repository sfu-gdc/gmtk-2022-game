extends Position3D

onready var trash := $"/root".get_child(get_tree().get_root().get_child_count() - 1).find_node("Trash")

func rotate_garbage():
	look_at(trash.global_transform.origin, Vector3.UP)
	rotation.x = 0.0
	rotation.z = 0.0
