extends KinematicBody

signal interact

onready var dice_tex_1 = load("res://art/white-die.png")
onready var dice_pool = get_tree().get_root().get_child(0).find_node("DicePool")
onready var dice_box = get_tree().get_root().get_child(0).find_node("DiceBox")
onready var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

export var interaction_range := 2.5

var velocity_xz := Vector3()
var velocity_y := Vector3()
var angular_accleration = 15
var speed = 10
var cur_speed = 0
onready var animationTree : AnimationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

var held_die : Die = null

func spawn_die():
	var rbody = Die.new()
	rbody.can_sleep = false
	dice_pool.add_child(rbody)
	rbody.mass = 5
	rbody.translation = dice_box.translation + Vector3.UP * 2.801
	# somewhat random
	rbody.angular_velocity = Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)) * 25
	rbody.linear_velocity = Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)).normalized() * 4
	rbody.rotate(Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1)).normalized(), rand_range(-PI, PI)) 
	
	var mesh = MeshInstance.new()
	mesh.mesh = CubeMesh.new()
	mesh.mesh.size = Vector3(1.2,1.2,1.2)
	mesh.mesh.material = SpatialMaterial.new()
	mesh.mesh.material.albedo_texture = dice_tex_1
	rbody.add_child(mesh)
	
	var shape = CollisionShape.new()
	shape.shape = BoxShape.new()
	shape.shape.extents = Vector3(0.6,0.6,0.6)
	rbody.add_child(shape)
	
# ------------------------------------


func _process(_delta):
	if (dice_box.translation - translation).length() < interaction_range:
		dice_box.player_is_near = true
	else:
		dice_box.player_is_near = false
		
	if Input.is_action_just_pressed("activate"):
		emit_signal("interact", self, held_die)
		# If near dice box, spawn a die
		if (dice_box.translation - translation).length() < interaction_range:
			spawn_die()
	# Try to pick up a die
	if Input.is_action_just_pressed("pick"):
		# Try to drop held dice
		if held_die:
			held_die.place()
			held_die = null
		# Otherwise, find the closest die
		else:
			var close_dice := {}
			for die in dice_pool.get_children():
				var distance : float = (die.translation - translation).length()
				if distance < interaction_range:
					close_dice[distance] = die
			# If there is a closest die
			if close_dice.size() > 0:
				var minimum_distance : float = close_dice.keys().min()
				# Pick up the closest die
				held_die = close_dice[minimum_distance].pickup(self)

func _physics_process(delta):
	
	if (Input.is_action_pressed("player_up") or Input.is_action_pressed("player_down") or
			Input.is_action_pressed("player_left") or Input.is_action_pressed("player_right")):
		animationState.travel("Run")
		velocity_xz = speed * Vector3(
								(Input.get_action_strength("player_right") - Input.get_action_strength("player_left")),
								 0,
								(Input.get_action_strength("player_down") - Input.get_action_strength("player_up"))
								).normalized()
		
		rotation.y = lerp_angle(rotation.y, atan2(-velocity_xz.x, -velocity_xz.z), delta * angular_accleration)
		
	else:
		animationState.travel("Idle")
		velocity_xz = Vector3()
	
	if is_on_floor():
		velocity_y = Vector3()
	else:
		velocity_y -= Vector3(0.0, gravity * delta, 0.0)
	
	move_and_slide(velocity_xz + velocity_y, Vector3.UP, false, 4, 0.785398, false)
