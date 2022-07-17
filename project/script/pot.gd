extends RigidBody

export var interaction_range : float = 20.0

const SMOKE_SCENE := preload("res://prefabs/effects/smoke.tscn")
const DIE_UI := preload("res://prefabs/DieUI.tscn")
const BURN_IMG := preload("res://art/dice-fire.png")
const DIE_COOK_TIME := 8.0
const BURN_TIME := 10.0

onready var player1 : KinematicBody = $"/root".get_child(get_tree().get_root().get_child_count() - 1).find_node("Player1")
onready var level : Spatial = $"/root".get_child(get_tree().get_root().get_child_count() - 1)
onready var UI : GridContainer = $DiceInPot
onready var cooking_progress : ProgressBar = $CookProgress
onready var fire_explosion : CPUParticles2D = $FireExplosion
onready var simmer : AudioStreamPlayer = $Simmer
onready var countdown : AudioStreamPlayer = $Countdown
var smoke : CPUParticles


const POT_LAYER := 1

var numbers := []
var cooking := false
var held := false
var dumping := false
var cooking_time := 0.0
var burnt := false

# is this object throwable or not
var throwable = false
# can catch a object and attach into it
var attachable = true

func _ready():
	var smoke_scene := SMOKE_SCENE.instance()
	smoke_scene.pot_to_follow = self
	level.call_deferred("add_child", smoke_scene)
	smoke = smoke_scene.get_node("smoke")

# warning-ignore:return_value_discarded
	player1.connect("interact", self, "_on_player_interact")

func _process(delta):
	if cooking_time >= numbers.size() * DIE_COOK_TIME + BURN_TIME and not burnt:
		burnt = true
		numbers.clear()
		fire_explosion.emitting = true
		UI.size_multiplier = 2.0
		UI.clear_dice()
		UI.margin_top = -UI.image_size * UI.size_multiplier
		var burn_img := DIE_UI.instance()
		burn_img.texture = BURN_IMG
		UI.add_child(burn_img)
	
	if not burnt and numbers.size() > 0 and cooking_time >= numbers.size() * DIE_COOK_TIME:
		if not countdown.playing:
			countdown.playing = true
		if cooking:
			countdown.stream_paused = false
	
	if burnt:
		cooking_progress.value = numbers.size() * DIE_COOK_TIME + BURN_TIME
	
	var fraction_to_burn := clamp(range_lerp(cooking_time, cooking_progress.max_value, BURN_TIME + cooking_progress.max_value, 1.0, 0.0), 0.0, 1.0)

	smoke.color = Color(fraction_to_burn, fraction_to_burn, fraction_to_burn)

	cooking_progress.value = cooking_time
	if cooking and numbers.size() > 0:
		cooking_time += delta

func _on_player_interact(player: KinematicBody, held_object: Spatial):
	if not held and not burnt and held_object is Die and to_local(player.global_transform.origin).length_squared() < interaction_range:
		# Make sure I'm the closest that can eat a die
		var player_position := player.global_transform.origin
		for node in get_tree().get_nodes_in_group("can_take_dice"):
			if node.global_transform.origin.distance_squared_to(player_position) < global_transform.origin.distance_squared_to(player_position):
				return

		numbers.append(held_object.number)
		held_object.pot(player, self)
		UI.add_die(held_object.number)
		smoke.emitting = cooking and numbers.size() > 0
		cooking_progress.max_value = numbers.size() * DIE_COOK_TIME
		print(numbers)
		$PutInPot.play()
		countdown.stop()
		
func _on_throwable_interact(held_object: Spatial):
		numbers.append(held_object.number)
		held_object.remove_from_group("pickup")
		UI.add_die(held_object.number)
		smoke.emitting = cooking and numbers.size() > 0
		cooking_progress.max_value = numbers.size() * DIE_COOK_TIME
		print(numbers)
    $PutInPot.play()
		countdown.stop()

func pickup(player: KinematicBody) -> Spatial:
	# Attach to player and disable collisions
	mode = RigidBody.MODE_STATIC
	collision_layer = 0
	collision_mask = 0
	var save_transform := global_transform
	get_parent().remove_child(self)
	player.get_node("PotSpot").add_child(self)
	global_transform = save_transform
	transform.origin = player.get_node("PotSpot").transform.translated(Vector3(0.0, -0.5, 0.0)).origin
	held = true
	cooking = false
	simmer.stop()
	smoke.emitting = cooking
	countdown.stream_paused = true
	return self

func place(player: KinematicBody):
	if not dumping:
		var position := player.get_node("PotSpot")
		var save_transform := global_transform
		if self in position.get_children():
			position.remove_child(self)
			level.add_child(self)
			global_transform = save_transform
			global_transform.origin = (global_transform.origin - 1.5 * player.global_transform.basis.z).snapped(Vector3(2.0, 2.0, 2.0))
		else:
			global_transform = save_transform
			global_transform.origin = global_transform.origin.snapped(Vector3(2.0, 2.0, 2.0))
		held = false
		mode = RigidBody.MODE_CHARACTER
		collision_layer = POT_LAYER
		collision_mask = POT_LAYER

		return true
	else:
		return false

func garbage(player: KinematicBody):
	$Dumping.play()
	dumping = true
	var animation := player.get_node("PotDump")
	player.get_node("PotSpot").rotate_garbage()
	animation.play("Dump")
	numbers.clear()
	UI.clear_dice()
	cooking_time = 0.0
	burnt = false
	UI.size_multiplier = 1.0
	UI.clear_dice()
	print(numbers)
	yield(animation, "animation_finished")
	dumping = false

func _on_Area_body_entered(body):
	if body.is_in_group("snap"):
		print("snapped")
		mode = RigidBody.MODE_STATIC
		$PutDownPot.play()
	if body.get_parent().is_in_group("burner"):
		cooking = true
		simmer.play()
		smoke.emitting = cooking and numbers.size() > 0
		print("cooking: ", cooking)
	
	if body.is_in_group("floor"):
		$Thump.play()
	
