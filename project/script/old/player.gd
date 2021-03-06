extends KinematicBody

onready var dice_tex_1 = load("res://art/white-die.png")
onready var dice_pool = get_parent().find_node("DicePool")
onready var dice_box = get_parent().find_node("DiceBox")
onready var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

export var pickup_range := 4.0

var velocity := Vector3(0,0,0)
var speed := 400.0
var held_die : Die = null

func spawn_die():
	var rbody = Die.new(1)
	dice_pool.add_child(rbody)
	
# ------------------------------------

func _process(_delta):
	if (dice_box.translation - translation).length() < pickup_range:
		dice_box.player_is_near = true
	else:
		dice_box.player_is_near = false
		
	if Input.is_action_just_pressed("activate"):
		# If near dice box, spawn a die
		if (dice_box.translation - translation).length() < pickup_range:
			spawn_die()
	# Try to pick up a die
	if Input.is_action_just_pressed("pick"):
		# Try to drop held dice
		if held_die:
			held_die.place(self)
			held_die = null
		# Otherwise, find the closest die
		else:
			var close_dice := {}
			for die in dice_pool.get_children():
				var distance : float = (die.translation - translation).length()
				if distance < pickup_range:
					close_dice[distance] = die
			# If there is a closest die
			if close_dice.size() > 0:
				var minimum_distance : float = close_dice.keys().min()
				# Pick up the closest die
				held_die = close_dice[minimum_distance].pickup(self)

func _physics_process(delta):
	if Input.is_action_pressed("player_left"):
		velocity.x = -delta * speed
	elif Input.is_action_pressed("player_right"):
		velocity.x = delta * speed
	else:
		velocity.x = velocity.x * 0.6
		
	if Input.is_action_pressed("player_up"):
		velocity.z = -delta * speed
	elif Input.is_action_pressed("player_down"):
		velocity.z = delta * speed
	else:
		velocity.z = velocity.z * 0.6
	
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP, true, 4, 0.785398, false)
