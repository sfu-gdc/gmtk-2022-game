extends Spatial

onready var player1 : KinematicBody = get_tree().get_root().get_child(get_tree().get_root().get_child_count()- 1).find_node("Player1")
onready var player2 : KinematicBody = get_tree().get_root().get_child(get_tree().get_root().get_child_count()- 1).find_node("Player2")
onready var trash : StaticBody = get_parent()

func _process(_delta):
	var d1 = trash.to_local(player1.global_transform.origin).length_squared()
	var d2 = trash.to_local(player2.global_transform.origin).length_squared()
	translation.y = max(6.0 - 0.2 * min(d1, d2), 0.0)
