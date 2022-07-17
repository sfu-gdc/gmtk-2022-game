extends KinematicBody

signal interact

onready var game_runner = get_node("/root/Level1/GameRunner")

onready var dice_tex_1 = load("res://art/white-die.png")
onready var dice_pool = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1).find_node("DicePool")
var dice_box_list = [] 
var serve_area_list = [] 

onready var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
export var interaction_range := 3.5
export var pickup_position := Vector3(0.0, 3.0, -0.75)

var velocity_xz := Vector3()
var velocity_y := Vector3()
var angular_accleration = 15
var speed = 10
var cur_speed = 0
onready var animationTree : AnimationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

onready var arrow_effect = $arrow

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
	return true
	#TODO: implement
	
func place_food() -> void:
	pass
	#TODO: implement
	

func _ready():
	for i in 10:
		var ref = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1).find_node("DiceBox"+str(i))
		if ref == null:
			break
		dice_box_list.append(ref)
		
	for i in 10:
		var ref = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1).find_node("ServeArea"+str(i))
		print("here")
		if ref == null:
			break
		serve_area_list.append(ref)

func _process(_delta):
	# update timer value
	die_spawn_timer -= _delta
	die_spawn_timer = max(0, die_spawn_timer)

	# inform dice_box to move up / down
	for dice_box in dice_box_list:
		if (dice_box.translation - translation).length() < interaction_range:
			dice_box.player_is_near = true
		else:
			dice_box.player_is_near = false
	  
	for serve_area in serve_area_list:
		if (serve_area.translation - translation).length() < interaction_range:
			serve_area.player_is_near = true
		else:
			serve_area.player_is_near = false

	if Input.is_action_just_pressed("activate"):
		emit_signal("interact", self, held_object)

		# If near dice box, spawn a die
		if die_spawn_timer == 0:
			$ActivateDieBox.play()
			for dice_box in dice_box_list:
				if (dice_box.translation - translation).length() < interaction_range:
					spawn_die(dice_box.translation)
					die_spawn_timer = 0.4
					break
		  
		# If near output area & have food in hand place it in.
		if food_in_hand_matches() && game_runner.out_going_recipes_number.size() != 0:
			for serve_area in serve_area_list:
				if (serve_area.translation - translation).length() < interaction_range:
					place_food()
					print(game_runner.out_going_recipes_number.size())
					print(game_runner.out_going_recipes_number[0])
					game_runner.completed_recipe(game_runner.out_going_recipes_number[0])
					#game_runner.completed_recipe(game_runner.out_going_recipes_number[0]) # will crash if empty?
					break
		  
	# Try to pick up a die
	if Input.is_action_just_pressed("pick"):
		# Try to drop held dice
		if held_object:
			picking_time = -1
			picking = false
			$DropObject.play()

			if held_object.place(self):
				held_object = null
		# Otherwise, find the closest die
		else:
			var close_objects := {}
			for object in get_tree().get_nodes_in_group("pickup"):
				var distance : float = (object.translation - translation).length()
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

				animationState.travel("PickUp")
				$GrabObject.play()

	# pickup delay for animation
	if picking && picking_time > 0:
		pickingUpAnimation(held_object, _delta)
		picking_time -= _delta
		if picking_time <= 0:
			picking = false
			held_object = held_object.pickup(self)

func pickingUpAnimation(object, delta):
	# the dice will travel a little bit before picked up
	var direction = transform.origin - object.transform.origin
	object.translation.x += direction.x * delta
	object.translation.y += direction.y * 0.5 + 1
	object.translation.z += direction.z * delta

func throwObject(delta, direction, hor_Force, vect_force):
	if Input.is_action_pressed("throw") && held_object:
		arrow_effect.visible = true
	else:
		arrow_effect.visible = false

	if Input.is_action_just_released("throw") && held_object:
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
			$WalkingSound.play()
			elapsed = 0
	else:
		animationState.travel("Idle")
		velocity_xz = Vector3()

	if is_on_floor():
		velocity_y = Vector3()
	else:
		velocity_y -= Vector3(0.0, gravity * delta, 0.0)

	throwObject(delta, transform.basis.z, 1250 , -100)
	# warning-ignore:return_value_discarded
	move_and_slide(velocity_xz + velocity_y, Vector3.UP, false, 4, 0.785398, false)
