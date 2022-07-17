extends RigidBody
class_name Die

onready var dice_pool := $"/root/Level1/DicePool"
onready var trash := $"/root".get_child($"/root".get_child_count()-1).find_node("Trash")

var start_location : Vector3

const DIE_LAYER := 1

var number : int = -1

var die_type: int = 0
var number_group: int = 0

# is this object throwable or not
var throwable = true
# throwing status will keep releasing signal
var throwing = false

onready var dice_tex_1 = load("res://art/white-die.png")

# for stopping & starting particles
var t1: Timer = Timer.new()
var t2: Timer = Timer.new()

func _init(arg):
	add_to_group("pickup")
	self.contact_monitor = true
	
	self.add_child(t1)
# warning-ignore:return_value_discarded
	t1.connect("timeout", self, "stop_particles")
	t1.set_wait_time(0.25)
	
	self.add_child(t2)	
# warning-ignore:return_value_discarded
	t2.connect("timeout", self, "free_particles")
	t2.set_wait_time(1.75)
	
	#collision checker


# this is so we can pass 2 params to the function
func init(die_type_local: int, start_location_local: Vector3):
	#collision checker
	self.contact_monitor = true
	self.contacts_reported = 5
	
	self.connect("body_entered", self, "_on_body_entered")
	
	self.die_type = die_type_local
	self.start_location = start_location_local

	print(start_location_local)
	
	self.can_sleep = false
	self.mass = 1
	#self.friction
	self.translation = start_location_local + Vector3.UP * 2.801
	# somewhat random

	self.angular_velocity = Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)) * 25
	self.linear_velocity = Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)).normalized() * 4
	self.rotate(Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)).normalized(), rand_range(-PI, PI)) 
	
	var mesh = MeshInstance.new()
	mesh.name = "MeshInstance"
	mesh.mesh = CubeMesh.new()
	mesh.mesh.size = Vector3(1.2,1.2,1.2)
	mesh.mesh.material = SpatialMaterial.new()
	if die_type_local == 0:
		mesh.mesh.material.albedo_texture = load("res://art/fulldie1.png")
	elif die_type_local == 1:
		var choices = [load("res://art/fulldie2.png"), load("res://art/fulldie3.png"), load("res://art/fulldie4.png")]
		number_group = randi() % choices.size()
		mesh.mesh.material.albedo_texture = choices[number_group]
	elif die_type_local == 2:
		pass
		
	mesh.mesh.material.uv1_scale = Vector3(1, 1, 1)
	self.add_child(mesh)

	var shape = CollisionShape.new()
	shape.shape = BoxShape.new()
	shape.shape.extents = Vector3(0.6,0.6,0.6)
	self.add_child(shape)
	
func finalize_number():
	var pillar1 = self.transform.xform(Vector3(0,0,1)).normalized()
	var pillar2 = self.transform.xform(Vector3(1,0,0)).normalized()
	var pillar3 = self.transform.xform(Vector3(0,0,-1)).normalized()
	var pillar4 = self.transform.xform(Vector3(-1,0,0)).normalized()
	var pillar5 = self.transform.xform(Vector3(0,1,0)).normalized()
	var pillar6 = self.transform.xform(Vector3(0,-1,0)).normalized()
	
	var pillar_list = [pillar1,pillar2,pillar3,pillar4,pillar5,pillar6]
	var closest_pillar = INF
	
	# compare against Vector3.UP
	for i in pillar_list.size():
		var dist = acos(Vector3.UP.dot(pillar_list[i]))
		if (dist < closest_pillar):
			closest_pillar = dist
			number = i + 1
		
	if die_type == 0:
		$MeshInstance.mesh.material.albedo_texture = load("res://art/dice/die_" + str(number) + ".png")
		$MeshInstance.mesh.material.uv1_scale = Vector3(3, 2, 1)
	elif die_type == 1:
		number += 6 + number_group * 6
		$MeshInstance.mesh.material.albedo_texture = load("res://art/dice/die_" + str(number) + ".png")
		$MeshInstance.mesh.material.uv1_scale = Vector3(3, 2, 1)
	else:
		number = 0 # err
		print("bad compute, no, stop")
	
	# play oneshot particle effect
	var particles = load("res://prefabs/effects/CompletionEventParticles.tscn").instance()
	particles.name = "ChildParticles"
	self.add_child(particles)
	
	particles.translation = Vector3.ZERO
	particles.get_node("CPUParticles").emitting = true
	t1.start()

func stop_particles():
	get_node("ChildParticles").get_node("CPUParticles").emitting = false
	t2.start()

func free_particles():
	get_node("ChildParticles").queue_free()
	t1.queue_free()
	t2.queue_free()

func _process(_delta):
	if linear_velocity.length() < 0.003 && number == -1:
		finalize_number()

func _on_body_entered(body:Node):
	#if die collised to "attachable" object
	if not "attachable" in body:
		return
	body._on_throwable_interact(self)
	queue_free()
	
func pickup(player: KinematicBody) -> Die:
	# Attach to player and disable collisions
	var save_transform := global_transform
	get_parent().remove_child(self)
	mode = RigidBody.MODE_STATIC
	collision_layer = 0
	collision_mask = 0
	player.add_child(self)
	global_transform = save_transform
	transform.origin = player.pickup_position
	
	return self

func place(player: KinematicBody):
	if not get_parent():
		return false
	var save_transform := global_transform
	player.remove_child(self)
	dice_pool.add_child(self)
	global_transform = save_transform
	global_transform.origin = (global_transform.origin - 1.0 * player.global_transform.basis.z)
	mode = RigidBody.MODE_RIGID
	collision_layer = DIE_LAYER
	collision_mask = DIE_LAYER
	
	return true

func garbage(player: KinematicBody):
	player.held_object = null
	remove_from_group("pickup")
	var save_transform := global_transform
	player.remove_child(self)
	dice_pool.add_child(self)
	global_transform = save_transform
	
	var yeet := Tween.new()
	add_child(yeet)
# warning-ignore:return_value_discarded
	yeet.interpolate_property(self, "global_transform:origin", null, trash.global_transform.origin, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
# warning-ignore:return_value_discarded
	yeet.start()
	yield(yeet, "tween_completed")
	queue_free()

func pot(player: KinematicBody, dump_pot: Spatial):
	player.held_object = null
	remove_from_group("pickup")
	var save_transform := global_transform
	player.remove_child(self)
	dice_pool.add_child(self)
	global_transform = save_transform
	
	var yeet := Tween.new()
	add_child(yeet)

	# warning-ignore:return_value_discarded
		yeet.interpolate_property(self, "global_transform:origin", null, dump_pot.global_transform.origin, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	# warning-ignore:return_value_discarded
	
	yeet.start()
	yield(yeet, "tween_completed")
	queue_free()
