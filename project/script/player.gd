extends KinematicBody

var velocity = Vector3(0,0,0)
var speed = 10
var direction = Vector3.ZERO

func _ready():
		
	axis_lock_motion_z = true
	axis_lock_motion_y = true

	pass
	
func _process(delta):
	if Input.is_action_pressed("player_left"):
		self.translation.x -= delta * 10
		character_rotation(delta)

	elif Input.is_action_pressed("player_right"):
		self.translation.x += delta * 10
		character_rotation(delta)

	elif Input.is_action_pressed("player_up"):
		self.translation.z -= delta * 10
		character_rotation(delta)

	elif Input.is_action_pressed("player_down"):
		self.translation.z += delta * 10
		character_rotation(delta)
		
	
func character_rotation(delta):
	var x = - self.translation.x * delta
	var z = - self.translation.z * delta
	
	var angle = atan2(x,z)

	var char_rotation:Vector3 = get_rotation()
	char_rotation.y = angle * 2
	
	set_rotation(char_rotation)
	
	
func _physics_process(delta):
	velocity.y -= 9.81 * delta
	velocity = self.move_and_slide(self.velocity, Vector3.UP)
	
	
	

