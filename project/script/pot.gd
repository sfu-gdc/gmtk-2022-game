extends RigidBody

export var interaction_range : float = 20.0

onready var player1 : KinematicBody = $"/root".get_child(0).find_node("Player1")
onready var level : Spatial = $"/root".get_child(0)
onready var UI : GridContainer = $DiceInPot

const POT_LAYER := 1

var numbers := []
var held := false

func _ready():
# warning-ignore:return_value_discarded
	player1.connect("interact", self, "_on_player_interact")

func _on_player_interact(player: KinematicBody, held_object: Spatial):
	if not held and held_object is Die and to_local(player.global_transform.origin).length_squared() < interaction_range:
		numbers.append(held_object.number)
		held_object.pot(player, self)
		UI.add_die(held_object.number)
		print(numbers)

func pickup(player: KinematicBody) -> Spatial:
	# Attach to player and disable collisions
	mode = RigidBody.MODE_STATIC
	collision_layer = 0
	collision_mask = 0
	var save_transform := global_transform
	get_parent().remove_child(self)
	player.get_node("PotSpot").add_child(self)
	global_transform = save_transform
	transform.origin = player.get_node("PotSpot").transform.translated(Vector3(0.0, -0.5, 0.0)).origin
	held = true
	return self

func place():
	var player = get_parent()
	var position = get_parent()
	var save_transform := global_transform
	position.remove_child(self)
	level.add_child(self)
	global_transform = save_transform
	global_transform.origin = (global_transform.origin - 1.5 * player.global_transform.basis.z).snapped(Vector3(2.0, 2.0, 2.0)) + 1.25 * Vector3.DOWN
	held = false
	mode = RigidBody.MODE_CHARACTER
	collision_layer = POT_LAYER
	collision_mask = POT_LAYER

func garbage(player: KinematicBody):
	player.get_node("PotDump").play("Dump")
	player.get_node("PotSpot").rotate_garbage()
	numbers.clear()
	UI.clear_dice()
	print(numbers)


func _on_Area_body_entered(body):
	if body.is_in_group("snap"):
		print("snapped")
		mode = RigidBody.MODE_STATIC
