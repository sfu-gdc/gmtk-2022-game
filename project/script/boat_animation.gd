extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var going_out = false
var going_in = false

onready var animationTree : AnimationTree = $AnimationTree
onready var animationPlayer: AnimationPlayer = $AnimationPlayer2
onready var animationState

# Called when the node enters the scene tree for the first time.
func _ready():
	animationState = animationTree.get("parameters/playback")
	pass # Replace with function body.

func _process(delta):
	if going_out && animationPlayer.current_animation == "Idle":
		animationState.travel("go_out")
		going_out = false
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
