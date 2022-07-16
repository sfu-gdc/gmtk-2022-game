extends RigidBody
class_name Die

export var pickup_height := 1.5

onready var dice_pool := $"/root/Level1/DicePool"
onready var dice_box := $"/root/Level1/Level/InnerWalls/DiceBox"

const DIE_LAYER := 1

var number : int
var die_type: int = 0
var number_group: int = 0

onready var dice_tex_1 = load("res://art/white-die.png")

func _init(die_type: int):
	self.die_type = die_type

func _ready():
	self.mass = 5
	self.translation = dice_box.translation + Vector3.UP * 2.801
	# somewhat random
	self.angular_velocity = Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)) * 25
	self.linear_velocity = Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)).normalized() * 4
	self.rotate(Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)).normalized(), rand_range(-PI, PI)) 
	
	var mesh = MeshInstance.new()
	mesh.mesh = CubeMesh.new()
	mesh.mesh.size = Vector3(1.2,1.2,1.2)
	mesh.mesh.material = SpatialMaterial.new()
	if die_type == 0:
		mesh.mesh.material.albedo_texture = load("res://art/fulldie1.png")
	elif die_type == 1:
		var choices = [load("res://art/fulldie2.png"), load("res://art/fulldie3.png"), load("res://art/fulldie4.png")]
		number_group = randi() % choices.size()
		mesh.mesh.material.albedo_texture = choices[number_group]
	elif die_type == 2:
		pass
		
	mesh.mesh.material.uv1_scale = Vector3(1, 1, 1)
	self.add_child(mesh)

	var shape = CollisionShape.new()
	shape.shape = BoxShape.new()
	shape.shape.extents = Vector3(0.6,0.6,0.6)
	self.add_child(shape)

	"""
	# set timer to finalize value
	var timer = Timer.new()
	timer.name = "NotePlayTimer"
	add_child(timer)
	
	timer.connect("timeout", self, "finalize_number")
	timer.set_wait_time(1)
	timer.start()
	"""
	
func finalize_number():
	if die_type == 0:
		number = randi() % 6
		$MeshInstance.mesh.material.albedo_texture = load("res://art/dice/die_" + str(number+1) + ".png")		
	elif die_type == 1:
		pass
	else:
		number = 0 # err
		print("bad compute, no, stop")
	print("finalized")

func pickup(player: KinematicBody) -> Die:
	# Attach to player and disable collisions
	var save_transform := global_transform
	get_parent().remove_child(self)
	mode = RigidBody.MODE_STATIC
	collision_layer = 0
	collision_mask = 0
	player.add_child(self)
	global_transform = save_transform
	global_transform.origin.y = pickup_height
	
	return self

func place():
	var player : KinematicBody = get_parent()
	var save_transform := global_transform
	player.remove_child(self)
	dice_pool.add_child(self)
	global_transform = save_transform
	mode = RigidBody.MODE_RIGID
	collision_layer = DIE_LAYER
	collision_mask = DIE_LAYER
