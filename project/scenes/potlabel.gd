extends Sprite3D

onready var camera : Camera = $"/root".get_child(-1).find_node("Camera")
onready var player1 : KinematicBody = get_tree().get_root().get_child(-1).find_node("Player1")

func _process(_delta):
	look_at(camera.translation, Vector3.UP)
	opacity = clamp(0.8 - 0.3 * to_local(player1.global_transform.origin).length(), 0.0, 0.5)
