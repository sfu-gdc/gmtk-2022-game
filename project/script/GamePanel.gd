extends Panel
var SettingsPanel = preload("res://prefabs/SettingsPanel.tscn")
var OrderCardList = preload("res://prefabs/OrderCardList.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _on_Button_pressed():
	var panel = SettingsPanel.instance();
	self.add_child(panel);
	return; # Replace with function body.


# Called when the node enters the scene tree for the first time.
func _ready():
	var order_card_list = OrderCardList.instance();
	self.add_child(order_card_list);
	return; # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


