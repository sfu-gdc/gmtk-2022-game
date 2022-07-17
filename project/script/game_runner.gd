extends Node

const ORDER_COST: int = 20

var order_card_list: Node = null
var game_panel: Node = null

const SMALL_ORDER_TIME = 25.0
var new_order_timer: float = 10.0

# this script manages running the game
var out_going_recipes_number = []
var out_going_recipes = []

func _ready():
	#get_tree().paused = true;
	randomize() # seed rng just in case

func post_ready():
	order_card_list = get_node("/root/Level1/GamePanel/OrderCardList")
	game_panel = get_node("/root/Level1/GamePanel/")

func _process(delta):
	new_order_timer -= delta
	
	# every 20s a new order is added
	if new_order_timer < 0:
		new_order_timer = SMALL_ORDER_TIME
		var num = random_small_number()
		var oc: Control = order_card_list.add(60, num)
		out_going_recipes.append(oc)
		out_going_recipes_number.append(num)
		oc.connect("card_complete_up", self, "remove_recipe", [oc, false])
	
	if order_card_list != null && out_going_recipes.size() == 0:
		var num = random_small_number()
		var oc: Control = order_card_list.add(60, num)
		out_going_recipes.append(oc)
		out_going_recipes_number.append(num)
		oc.connect("card_complete_up", self, "remove_recipe", [oc, false])
	
	if order_card_list == null:
		post_ready()

# public function ###############
func completed_recipe(number: int):
	var i: int = out_going_recipes_number.find(number)
	var oc: Control = out_going_recipes[i]
	if !oc.delete_card():
		return
	else:
		oc.disconnect("card_complete_up", self, "remove_recipe")
		remove_recipe(oc, true)

func remove_recipe(card, was_successful):
	var i = out_going_recipes.find(card)
	out_going_recipes.pop_at(i)
	out_going_recipes_number.pop_at(i)
	
	if was_successful:
		game_panel.gold_increase(ORDER_COST)
		new_order_timer -= 5.0
	else:
		game_panel.gold_decrease(ORDER_COST)
		
func random_small_number():
	return randi() % 8 + 5 # ~[5, 15]
