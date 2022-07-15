extends KinematicBody

var velocity = Vector3(0,0,0)
var speed = 400

func _ready():
	pass
	
func _process(delta):
	pass

func _physics_process(delta):
	if Input.is_action_pressed("player_left"):
		self.velocity.x = -delta * speed
	elif Input.is_action_pressed("player_right"):
		self.velocity.x = delta * speed
	else:
		self.velocity.x = self.velocity.x * 0.6
		
	if Input.is_action_pressed("player_up"):
		self.velocity.z = -delta * speed
	elif Input.is_action_pressed("player_down"):
		self.velocity.z = delta * speed
	else:
		self.velocity.z = self.velocity.z * 0.6
		
	#velocity.y -= 9.81 * delta
	velocity = self.move_and_slide(self.velocity, Vector3.UP)
