extends StaticBody

export var interaction_range : float = 15.0

onready var player1 : KinematicBody = $"/root".get_child(get_tree().get_root().get_child_count() - 1).find_node("Player1")

# is this object throwable or not
var throwable = false
# can catch a object and attach into it
var attachable = true


func _ready():
# warning-ignore:return_value_discarded
	player1.connect("interact", self, "_on_player_interact")
#	self.connect("body_entered", self, "_on_body_entered")

func _on_player_interact(player: KinematicBody, held_object: Spatial):
	if held_object and to_local(player.global_transform.origin).length_squared() < interaction_range:
		
		# Make sure I'm the closest that can eat dice
		var player_position := player.global_transform.origin
		for node in get_tree().get_nodes_in_group("can_take_dice"):
			if node.global_transform.origin.distance_squared_to(player_position) < global_transform.origin.distance_squared_to(player_position):
				return
		
		assert(held_object.has_method("garbage"), "held object needs a 'garbage' method")
		held_object.garbage(player)

func _on_throwable_interact(held_object: Spatial):
		held_object.remove_from_group("pickup")
