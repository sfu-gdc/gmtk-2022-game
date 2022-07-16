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
var OrderCard : PackedScene = preload("res://UI/OrderCardList/OrderCard/OrderCard.tscn")

onready var tween : Tween = $Tween

# emitted when the cards starts moving or stops moving
signal move_state_changes

func change_in_movement(moves: bool):
	print("changing movement to :"+str(moves));
	is_moving = moves
	emit_signal("move_state_changes")

func _ready():
	# create a temporary order card instance, get the x size of it and delete the node
	var temp_card = OrderCard.instance()
	card_size = temp_card.get_node("Panel").get_size().x
	temp_card.queue_free()
	
	# create a connection that when move_state_changes is emitted, call add card method
	connect("move_state_changes", self, "add_card_child")
		
func _unhandled_input(event: InputEvent):
	if event.is_pressed() and event.scancode == KEY_ENTER:
		print("status: "+str(is_moving));
	if event.is_pressed() and event.scancode == KEY_SPACE:
		create_order_card(1)

func add_card_child():
	if (!is_moving):
		while order_card_buffer:
			print(order_card_buffer)
			# pop the the most front card 
			var card = order_card_buffer.pop_front()
			# add the order card into the scene tree as a child 
			add_child(card)
			# append the newest order card in the list
			order_card_list.append(card)
		

# create a new order card
func create_order_card(timer_time):
	# create a new order card, and add it to the current node
	var order_card_instance : Control = OrderCard.instance()
	# the position x of the order card is determined by 
	# offset + (horizontal margin + horizontal order card size) * the amount of cards beforehand
	var x = hoffset + (hmargin + card_size) * order_card_list.size()
	
	# initialize the order
	order_card_instance.__init(timer_time, x)
	
	# if card is existing from tree, reorder the card list
	order_card_instance.connect("tree_exiting", self, "reorder_order_card_list", [order_card_instance])
	
	# if the card is not moving, add the card to the scene tree then to the lease
	if !is_moving:
		# add the order card into the scene tree as a child 
		add_child(order_card_instance)
		# append the newest order card in the list
		order_card_list.append(order_card_instance)
	else:  # if the card is moving, add to the buffer
		order_card_buffer.append(order_card_instance)
		

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
					print("i am the last one");
					tween.interpolate_property(card, "rect_position:x", card.rect_position.x, 
							card.rect_position.x- move_left_amount, 1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
				tween.start()
				print("starting the tween");
				self.is_moving = true;
				
				yield(tween, "tween_completed");
				self.is_moving = false
			break
