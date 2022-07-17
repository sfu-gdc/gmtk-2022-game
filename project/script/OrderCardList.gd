extends Control

# horizontal margin size
export var hmargin : int = 10
# horizontal offset
export var hoffset : int = 15
# the horizontal size of the card
var card_size : int = 0
# whether the cards are shifting to the left
var is_moving : bool = false setget change_in_movement

# a list of order cards
var order_card_list = []
# a list of cards to be buffered when cards are moving
var order_card_buffer = []

# get the OrderCard scene in file system
var OrderCard : PackedScene = preload("res://prefabs/OrderCard.tscn")

onready var tween : Tween = $Tween

# emitted when the cards starts moving or stops moving
signal move_state_changes


var rng
# setter for is_moving, emit the signal "move_state_changes" whenever is_moving value changes
func change_in_movement(moves: bool):
	is_moving = moves
	emit_signal("move_state_changes")

func _ready():
	# create a temporary order card instance, get the x size of it and delete the node
	var temp_card = OrderCard.instance()
	card_size = temp_card.get_node("Panel").get_size().x
	temp_card.queue_free()

	# create a connection that when move_state_changes is emitted, call add card method
	var _v1 = connect("move_state_changes", self, "add_card_child")
	
	rng = RandomNumberGenerator.new()

# warning-ignore:unused_argument
func _physics_process(_delta):
	if Input.is_action_just_pressed("down"):
		var new_number = rng.randi_range(1, 50)
		print(new_number)
		add(1, new_number)

# called when move_state_changes occur. If it's not moving, add the cards from buffer
func add_card_child():
	# if cards are not moving to the left
	if (!is_moving):
		# while there exists a card in the buffer; while loop stops when there isn't a card in buffer
		while order_card_buffer:
			# pop the the most front card
			var card = order_card_buffer.pop_front()
			# set the position x of the card
			set_card_x(card)
			# add the card to the list, set its connection, and add it to the tree
			add_card(card)

# check whether it's a good time to create and add the order card
func add(timer_time: float, num: int):
	# if the cards are not shifting to the left, start creating order card, as the animation shoulnd't be interrupted
	if !is_moving:
		create_order_card(timer_time, num)
	# if the cards are shifting to the left, add a card to the buffer with its parameter already specified
	else:
		var order_card_instance : Control = instance_order_card(timer_time, num)
		order_card_buffer.append(order_card_instance)


# create a new order card
func create_order_card(timer_time: float, num: int) -> void:
	# creates an order card instance with timer wait time specified
	var order_card_instance = instance_order_card(timer_time, num)

	# set the card's x position
	set_card_x(order_card_instance)

	# add the card to the scene tree
	add_card(order_card_instance)

# add the card to the list, connect it for signals, and add the card as a child of this node
func add_card(order_card_instance: Control) -> void:
	# append the newest order card to the list
	order_card_list.append(order_card_instance)

	# if card is exiting from tree, reorder the card list
# warning-ignore:return_value_discarded
	order_card_instance.connect("card_complete_up", self, "reorder_order_card_list", [order_card_instance])

	# add the order card into the scene tree as a child
	add_child(order_card_instance)

# set the x position of the card
func set_card_x(order_card_instance: Control) -> void:
	# the position x of the order card is determined by
	# offset + (horizontal margin + horizontal order card size) * the amount of cards beforehand
	var x = hoffset + (hmargin + card_size) * order_card_list.size()
	# initailize the x position of the order card
	order_card_instance._init_set_x(x)

# instance an order card, with its timer wait time, number defined
func instance_order_card(timer_time: float, number: int) -> Control:
	# create a new order card, and add it to the current node
	var order_card_instance : Control = OrderCard.instance()
	# initialize the order card with the timer wait time
	order_card_instance._init_set_timer(timer_time)
	order_card_instance._init_set_text(str(number))
	return order_card_instance  # return the card as the instance

# reorder the order of the cards from the list by shifting to the left
func reorder_order_card_list(order_card_instance):
	# amount of pixel each card needs to move left for after reordering the list
	var move_left_amount = hmargin + card_size
	# go through the order card list, find the card that equals to the order_card_instance
	for index in order_card_list.size():
		# if any element equals to the card we are searching for, remove that card from list
		# and move all the cards from its back to front
		if order_card_instance == order_card_list[index]:
			order_card_list.remove(index)  # remove the card found
			# if the card removed is not the last card, tween to the left
			if order_card_list.size() > index:
				# for each of the card in the back, move them to front for one
				for card in order_card_list.slice(index, -1):
					# start the tween for the cards by moving the cards from the back to the front
# warning-ignore:return_value_discarded
					tween.interpolate_property(card, "rect_position:x", card.rect_position.x,
							card.rect_position.x- move_left_amount, 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
				# start the tween
# warning-ignore:return_value_discarded
				tween.start()
				# set the is_moving to true, since cards are moving to the left
				self.is_moving = true
				# wait for the tween to get all completed
				yield(tween, "tween_all_completed")
				# set is moving to false, as cards are no longer moving
				self.is_moving = false
			# break as we no longer need to search for other cards with the main card we found
			break
