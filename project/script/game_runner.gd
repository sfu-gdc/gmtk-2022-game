extends Node

var out_going_recipes = []

func _ready():
	pass 

func _process(delta):
	if out_going_recipes.size() == 0:
		out_going_recipes.append(random_small_number())
		

func random_small_number():
	return randi() & 10
