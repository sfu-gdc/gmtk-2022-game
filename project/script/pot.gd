extends Spatial

export var interaction_range : float = 20.0

onready var player1 : KinematicBody = $"/root".get_child(0).find_node("Player1")

var numbers := []

func _ready():
	player1.connect("interact", self, "_on_player_interact")

func _on_player_interact(player: KinematicBody, held_object: Spatial):
	if held_object is Die and to_local(player.global_transform.origin).length_squared() < interaction_range:
		numbers.append(held_object.number)
		player.held_object = null
		held_object.queue_free()
		print(numbers)
