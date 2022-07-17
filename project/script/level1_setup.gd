extends Node

# this script is for initializing relationships in the scene graph

var current_slide = 1;
var total_num_slide = 2;
var time_left = 150;

func _ready():
	spwan_tutorial()

func spwan_tutorial():
	get_tree().paused = true;
	# TODO: attach pots to their burners

func _on_TutorialNextButton_pressed():
	if (current_slide >= total_num_slide):
		self.find_node("Backdrop").hide();
		get_tree().paused = false;
		self.find_node("GameTimer").start();
		self.find_node("GameTimerText").start();
		return

	self.find_node("Tutorial"+str(current_slide)).hide();
	current_slide+=1;
	self.find_node("Tutorial"+str(current_slide)).show();
	
	if (current_slide == total_num_slide):
		self.find_node("NextButton").get_child(0).bbcode_text = "[center]start game[/center]";

func _on_TutorialPrevButton_pressed():
	if (current_slide == 1):
		return;
	
	self.find_node("Tutorial"+str(current_slide)).hide();
	current_slide-=1;
	self.find_node("Tutorial"+str(current_slide)).show();
	
	if (current_slide != total_num_slide):
		self.find_node("NextButton").get_child(0).bbcode_text = "[center]Next[/center]";
	pass # Replace with function body.


func _on_GameTimerText_timeout():
	time_left -= 1;
	var minute_left:String = str(int(time_left/60))
	var second_left = time_left - int(minute_left)*60;
	var second_left_text = str(second_left);
	if (int(minute_left) > 0 && second_left < 10):
		second_left_text = "0"+second_left_text;
	var time_left_text = second_left_text;
	if (int(minute_left) > 0):
		time_left_text = minute_left+":"+time_left_text
	self.find_node("timer_text").bbcode_text = "[center]"+time_left_text+"[/center]";

