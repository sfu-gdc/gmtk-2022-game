extends Node

# this script is for initializing relationships in the scene graph

var current_slide = 1;
var total_num_slide = 2;

func _ready():
	#spwan_tutorial()
	pass

func spwan_tutorial():
	get_tree().paused = true;
	pass	
	# TODO: attach pots to their burners

func _on_TutorialNextButton_pressed():
	if (current_slide >= total_num_slide):
		self.find_node("Backdrop").hide();
		get_tree().paused = false;
		return;
	
	self.find_node("Tutorial"+str(current_slide)).hide();
	current_slide+=1;
	self.find_node("Tutorial"+str(current_slide)).show();
	
	if (current_slide == total_num_slide):
		self.find_node("NextButton").get_child(0).bbcode_text = "[center]start game[/center]";
	pass # Replace with function body.

func _on_TutorialPrevButton_pressed():
	if (current_slide == 1):
		return;
	
	self.find_node("Tutorial"+str(current_slide)).hide();
	current_slide-=1;
	self.find_node("Tutorial"+str(current_slide)).show();
	
	if (current_slide != total_num_slide):
		self.find_node("NextButton").get_child(0).bbcode_text = "[center]Next[/center]";
	pass # Replace with function body.
