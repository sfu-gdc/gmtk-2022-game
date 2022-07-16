extends StaticBody

export var interaction_range : float = 15.0

onready var player1 : KinematicBody = $"/root".get_child(0).find_node("Player1")

func _ready():
	player1.connect("interact", self, "_on_player_interact")

func _on_player_interact(player: KinematicBody, held_object: Spatial):
	if held_object and to_local(player.global_transform.origin).length_squared() < interaction_range:
		assert(held_object.has_method("garbage"), "held object needs a 'garbage' method")
		held_object.garbage(player)
