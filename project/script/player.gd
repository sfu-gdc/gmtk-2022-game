extends KinematicBody

var velocity = Vector3(0,0,0)

func _ready():
	pass
	
func _process(delta):
	if Input.is_action_pressed("player_left"):
		self.translation.x -= delta * 10
	elif Input.is_action_pressed("player_right"):
		self.translation.x += delta * 10
	elif Input.is_action_pressed("player_up"):
		self.translation.z -= delta * 10
	elif Input.is_action_pressed("player_down"):
		self.translation.z += delta * 10

func _physics_process(delta):
	velocity.y -= 9.81 * delta
	velocity = self.move_and_slide(self.velocity, Vector3.UP)

