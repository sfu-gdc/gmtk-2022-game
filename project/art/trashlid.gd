extends Spatial

onready var player1 : KinematicBody = get_tree().get_root().get_child(0).find_node("Player1")
onready var trash : StaticBody = get_parent()

func _process(_delta):
	translation.y = max(3.0 - 0.2 * trash.to_local(player1.global_transform.origin).length_squared(), 0.0)
