extends KinematicBody

onready var dice_tex_1 = load("res://art/white-die.png")

onready var dice_pool = get_parent().find_node("DicePool")
onready var dice_box = get_parent().find_node("DiceBox")

var velocity = Vector3(0,0,0)
var speed = 400

func spawn_die():
	var sbody = RigidBody.new()
	dice_pool.add_child(sbody)
	sbody.translation = dice_box.translation + Vector3.UP * 2.801
	# somewhat random
	sbody.angular_velocity = Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)) * 100
	sbody.rotate(Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)).normalized(), rand_range(-PI, PI)) 
	
	var mesh = MeshInstance.new()
	mesh.mesh = CubeMesh.new()
	mesh.mesh.size = Vector3(1,1,1)
	mesh.mesh.material = SpatialMaterial.new()
	mesh.mesh.material.albedo_texture = dice_tex_1
	sbody.add_child(mesh)
	
	var shape = CollisionShape.new()
	shape.shape = BoxShape.new()
	shape.shape.extents = Vector3(0.5,0.5,0.5)
	sbody.add_child(shape)
	
# ------------------------------------

func _ready():
	pass
	
func _process(delta):
	if (dice_box.translation - translation).length() < 2.5:
		dice_box.player_is_near = true
	else:
		dice_box.player_is_near = false
	
	if Input.is_key_pressed(KEY_E):
		if (dice_box.translation - translation).length() < 2.5:
			spawn_die()

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
