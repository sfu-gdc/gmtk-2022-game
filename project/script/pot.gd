extends Spatial

export var interaction_range : float = 6.75

onready var player1 : KinematicBody = $"/root".get_child(0).find_node("Player1")

func _ready():
	player1.connect("interact", self, "_on_player_interact")


func _on_player_interact(player: KinematicBody, held_die: Die):
	if to_local(player.global_transform.origin).length_squared() < interaction_range:
		pass
