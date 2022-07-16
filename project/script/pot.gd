extends Spatial

export var interaction_range : float = 20.0

onready var player1 : KinematicBody = $"/root".get_child(0).find_node("Player1")
onready var level : Spatial = $"/root".get_child(0)

var numbers := []
var held := false

func _ready():
	player1.connect("interact", self, "_on_player_interact")

func _on_player_interact(player: KinematicBody, held_object: Spatial):
	if not held and held_object is Die and to_local(player.global_transform.origin).length_squared() < interaction_range:
		numbers.append(held_object.number)
		player.held_object = null
		held_object.queue_free()
		print(numbers)

func pickup(player: KinematicBody) -> Spatial:
	# Attach to player and disable collisions
	var save_transform := global_transform
	get_parent().remove_child(self)
	player.add_child(self)
	global_transform = save_transform
	transform.origin = player.pickup_position
	held = true
	return self

func place():
	var player : KinematicBody = get_parent()
	var save_transform := global_transform
	player.remove_child(self)
	level.add_child(self)
	global_transform = save_transform
	held = false

func garbage(player: KinematicBody):
	numbers.clear()
	print(numbers)
