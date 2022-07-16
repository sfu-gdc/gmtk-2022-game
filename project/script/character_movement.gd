extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var velocity: Vector3 = Vector3.FORWARD
var angular_accleration = 15
var speed = 10
var cur_speed = 0
onready var animationTree:AnimationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	
	
	if (Input.is_action_pressed("player_up") || Input.is_action_pressed("player_down")||
	 Input.is_action_pressed("player_left") || Input.is_action_pressed("player_right")):
		animationState.travel("Run")
		velocity = Vector3(
		(Input.get_action_strength("player_right") - Input.get_action_strength("player_left")),
		 0,
		(Input.get_action_strength("player_down") - Input.get_action_strength("player_up"))
		).normalized()
		cur_speed = speed
		self.rotation.y = lerp_angle(self.rotation.y, atan2(-velocity.x, -velocity.z), delta * angular_accleration)
		self.move_and_slide(velocity * cur_speed, Vector3.UP)
		
		
	else:
		animationState.travel("Idle")
		cur_speed = 0
		




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
