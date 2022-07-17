extends KinematicBody

signal interact

var player_number: int

onready var game_runner = get_node("/root/Level1/GameRunner")

onready var dice_tex_1 = load("res://art/white-die.png")
onready var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
onready var walk_sound 
onready var level := get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
onready var dice_pool = level.find_node("DicePool")

onready var Boat = level.find_node("Boat")

var dice_box_list = [] 
var serve_area_list = [] 
export var interaction_range := 3.5
export var pickup_position := Vector3(0.0, 3.0, -0.75)

var velocity_xz := Vector3()
var velocity_y := Vector3()
var angular_accleration = 15
var speed = 10
var cur_speed = 0
onready var animationTree : AnimationTree
onready var animationState 

onready var arrow_effect

var die_spawn_timer = 0

var held_object : Spatial = null

var picking = false
var picking_time = 0

func spawn_die(location: Vector3):
	var rbody = Die.new(1) # TODO: get arg based on group that diceblock is in
	rbody.init(0, location)
	dice_pool.add_child(rbody)

# ------------------------------------

func food_in_hand_matches() -> bool:
	return held_object and held_object.get_filename() == "res://prefabs/Dish.tscn" and held_object.number in game_runner.out_going_recipes_number

func place_food(serve_area: MeshInstance) -> void:
	var yeet := Tween.new()
	held_object.place(self)
	held_object.mode = RigidBody.MODE_STATIC
	held_object.collision_layer = 0
	held_object.collision_mask = 0
#	var save_transform := global_transform.origin
#	visible = false
#	remove_child(held_object)
#	translation = level.to_local(save_transform)
#	level.add_child(held_object)
#	visible = true
#	global_transform.origin = save_transform
	held_object.add_child(yeet)
	yeet.interpolate_property(held_object, "global_transform:origin", null, serve_area.global_transform.origin + 1.5 * Vector3.UP, 0.3)
	yeet.start()
	yield(yeet, "tween_completed")
	held_object.get_node("CPUParticles").emitting = true
	get_node("/root/Level1/Player"+str(player_number)+"/KinematicBody"+str(player_number)+"/SubmitDish").stream.loop = false;
	get_node("/root/Level1/Player"+str(player_number)+"/KinematicBody"+str(player_number)+"/SubmitDish").play();
	var t = Timer.new()
	t.set_wait_time(1.5)
	t.set_one_shot(true)
	held_object.add_child(t)
	t.start()
	yield(t, "timeout")
	
	if (held_object != null):
		held_object.queue_free()
		held_object = null
	
func _ready():
	if self.name == "KinematicBody1":
		player_number = 1
	elif self.name == "KinematicBody2":
		player_number = 2
	else:
		print("please rename the char")
	
	for i in 10:
		var ref = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1).find_node("DiceBox"+str(i))
		if ref == null:
			break
		dice_box_list.append(ref)
		
	for i in 10:
		var ref = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1).find_node("ServeArea"+str(i))
		if ref == null:
			break
		serve_area_list.append(ref)

	animationTree = get_node("/root/Level1/Player"+str(player_number)+"/KinematicBody"+str(player_number)+"/AnimationTree")
	animationState = animationTree.get("parameters/playback")
	arrow_effect = get_node("/root/Level1/Player"+str(player_number)+"/KinematicBody"+str(player_number)+"/arrow")
	walk_sound = get_node("/root/Level1/Player"+str(player_number)+"/KinematicBody"+str(player_number)+"/WalkingSound")
	
func _process(_delta):
	# update timer value
	die_spawn_timer -= _delta
	die_spawn_timer = max(0, die_spawn_timer)

	# inform dice_box to move up / down
	for dice_box in dice_box_list:
		if (dice_box.global_transform.origin - global_transform.origin).length() < interaction_range:
			dice_box.player_is_near[player_number-1] = true
		else:
			dice_box.player_is_near[player_number-1] = false
	  
	for serve_area in serve_area_list:
		if (serve_area.global_transform.origin - global_transform.origin).length() < interaction_range:
			serve_area.player_is_near[player_number-1] = true
		else:
			serve_area.player_is_near[player_number-1] = false

	if (player_number == 1 && Input.is_action_just_pressed("activate")) || (player_number == 2 && Input.is_action_just_pressed("player2_activate")):
		emit_signal("interact", self, held_object)

		# If near dice box, spawn a die
		if die_spawn_timer == 0:
			for dice_box in dice_box_list:
				if (dice_box.global_transform.origin - global_transform.origin).length() < interaction_range:
					get_node("/root/Level1/Player"+str(player_number)+"/KinematicBody"+str(player_number)+"/ActivateDieBox").play()
					spawn_die(dice_box.translation)
					die_spawn_timer = 0.4
					break
		  
		# If near output area & have food in hand place it in.
		if food_in_hand_matches():
			for serve_area in serve_area_list:
				if (serve_area.global_transform.origin - global_transform.origin).length() < interaction_range:
					game_runner.completed_recipe(held_object.number)
					place_food(serve_area)
					if Boat && "going_out" in Boat:
						Boat.going_out = true
						#print("boat:", Boat.going_out)
					
					#print(game_runner.out_going_recipes_number.size())
					#print(game_runner.out_going_recipes_number[0])
					break
		  
	# Try to pick up a die
	if (player_number == 1 && Input.is_action_just_pressed("pick")) || (player_number == 2 && Input.is_action_just_pressed("player2_pick")):
		# Try to drop held dice
		if held_object:
			picking_time = -1
			picking = false

			if held_object.place(self):
				if "throwing" in held_object:
					held_object.throwing = true
				held_object = null
		# Otherwise, find the closest die
		else:
			var close_objects := {}
			for object in get_tree().get_nodes_in_group("pickup"):
				var distance : float = (object.global_transform.origin - global_transform.origin).length()
				if distance < interaction_range+1.0: # +1 for height
					close_objects[distance] = object
			# If there is a closest object
			if close_objects.size() > 0:
				# Pick up the closest die
				var minimum_distance : float = close_objects.keys().min()
				held_object = close_objects[minimum_distance]
				#setup picking animation offset
				picking = true
				picking_time = 20 * _delta
				get_node("/root/Level1/Player"+str(player_number)+"/KinematicBody"+str(player_number)+"/GrabObject").play()
				animationState.travel("PickUp")
	
	if !is_instance_valid( held_object ) || held_object == null:
		return
		
	# pickup delay for animation
	if picking && picking_time > 0:
		pickingUpAnimation(held_object, _delta)
		picking_time -= _delta
		if picking_time <= 0:
			picking = false
			held_object = held_object.pickup(self)

func pickingUpAnimation(object, delta):
	if !is_instance_valid( object ) || object == null:
		return
		
	# the dice will travel a little bit before picked up
	var direction = global_transform.origin - object.global_transform.origin
	object.global_transform.origin.x += direction.x * delta
	object.global_transform.origin.y += direction.y * 0.5 + 1
	object.global_transform.origin.z += direction.z * delta

func throwObject(delta, direction, hor_Force, vect_force):
	if ((player_number == 1 && Input.is_action_pressed("throw")) || (player_number == 2 && Input.is_action_pressed("player2_throw"))) && held_object:
		arrow_effect.visible = true
	else:
		arrow_effect.visible = false

	if ((player_number == 1 && Input.is_action_just_released("throw")) || (player_number == 2 &&Input.is_action_just_released("player2_throw"))) && held_object:
		if held_object.throwable:
			animationState.travel("Throw")
			picking_time = -1
			picking = false
			held_object.throwing = true
			held_object.global_transform.origin.y = held_object.global_transform.origin.y - 1.2
			held_object.add_central_force(Vector3(-direction.x * hor_Force, vect_force , -direction.z * hor_Force))

		if held_object.place(self):
			held_object = null

var elapsed: float
func _physics_process(delta):
	elapsed += delta
	
	# copy pasted b/c faster
	if player_number == 1:
		if (Input.is_action_pressed("player_up") or Input.is_action_pressed("player_down") or
				Input.is_action_pressed("player_left") or Input.is_action_pressed("player_right")):
			animationState.travel("Run")
			velocity_xz = speed * Vector3(
									(Input.get_action_strength("player_right") - Input.get_action_strength("player_left")),
									 0,
									(Input.get_action_strength("player_down") - Input.get_action_strength("player_up"))
									).normalized()

			rotation.y = lerp_angle(rotation.y, atan2(-velocity_xz.x, -velocity_xz.z), delta * angular_accleration)

			if elapsed > 0.2:
				if not walk_sound.playing:
					walk_sound.play()
				elapsed = 0
		else:
			animationState.travel("Idle")
			velocity_xz = Vector3()
	elif player_number == 2:
		if (Input.is_action_pressed("player2_up") or Input.is_action_pressed("player2_down") or
				Input.is_action_pressed("player2_left") or Input.is_action_pressed("player2_right")):
			animationState.travel("Run")
			velocity_xz = speed * Vector3(
									(Input.get_action_strength("player2_right") - Input.get_action_strength("player2_left")),
									 0,
									(Input.get_action_strength("player2_down") - Input.get_action_strength("player2_up"))
									).normalized()

			rotation.y = lerp_angle(rotation.y, atan2(-velocity_xz.x, -velocity_xz.z), delta * angular_accleration)

			if elapsed > 0.2:
				if not walk_sound.playing:
					walk_sound.play()
				elapsed = 0
		else:
			animationState.travel("Idle")
			velocity_xz = Vector3()

	if is_on_floor():
		velocity_y = Vector3()
	else:
		velocity_y -= Vector3(0.0, gravity * delta, 0.0)

	throwObject(delta, global_transform.basis.z, 1250 , -100)
	# warning-ignore:return_value_discarded
	move_and_slide(velocity_xz + velocity_y, Vector3.UP, false, 4, 0.785398, false)
