extends Node

var order_card_list: Node = null

# this script manages running the game
var out_going_recipes_number = []
var out_going_recipes = []

func _ready():
	randomize() # seed rng just in case

func post_ready():
	order_card_list = get_node("/root/Level1/GamePanel/OrderCardList")

func _process(delta):
	if order_card_list != null && out_going_recipes.size() == 0:
		var num = random_small_number()
		var oc: Control = order_card_list.add(4, num) ## should be 30
		out_going_recipes.append(oc)
		out_going_recipes_number.append(num)
		oc.connect("card_complete_up", self, "remove_recipe", [oc])
		
	if order_card_list == null:
		post_ready()

func remove_recipe(card):
	var i = out_going_recipes.find(card)
	out_going_recipes.pop_at(i)
	out_going_recipes_number.pop_at(i)
	
	print("did this")
	
func random_small_number():
	return randi() & 10
