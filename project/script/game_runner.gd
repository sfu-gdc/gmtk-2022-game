extends Node

const ORDER_COST: int = 20

var order_card_list: Node = null
var game_panel: Node = null

# this script manages running the game
var out_going_recipes_number = []
var out_going_recipes = []

func _ready():
	randomize() # seed rng just in case

func post_ready():
	order_card_list = get_node("/root/Level1/GamePanel/OrderCardList")
	game_panel = get_node("/root/Level1/GamePanel/")

func _process(delta):
	if order_card_list != null && out_going_recipes.size() == 0:
		var num = random_small_number()
		var oc: Control = order_card_list.add(4, num) ## should be 30
		out_going_recipes.append(oc)
		out_going_recipes_number.append(num)
		oc.connect("card_complete_up", self, "remove_recipe", [oc, false])
	
	if order_card_list == null:
		post_ready()

func completed_recipe(oc: Control):
	#oc.delete_card() # TODO: enable this
	remove_recipe(oc, true)

func remove_recipe(card, was_successful):
	var i = out_going_recipes.find(card)
	out_going_recipes.pop_at(i)
	out_going_recipes_number.pop_at(i)
	
	if was_successful:
		game_panel.gold_increase(ORDER_COST)
	else:
		game_panel.gold_decrease(ORDER_COST)
		
func random_small_number():
	return randi() & 10 + 3 # ~[3, 12]