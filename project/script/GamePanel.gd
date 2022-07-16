extends Control
var SettingsPanel = preload("res://prefabs/SettingsPanel.tscn")
var OrderCardList = preload("res://prefabs/OrderCardList.tscn")


var settings_spawned := false

var gold = 1100;

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventKey and event.is_pressed() && event.scancode in [KEY_BRACKETLEFT, 125] ):
		gold_increase(100);
	if (event is InputEventKey and event.is_pressed() && event.scancode in [KEY_BRACKETRIGHT, 123]):
		gold_decrease(100);

func gold_increase(amount):
	gold_change(gold+amount);
	
func gold_decrease(amount):
	gold_change(max(gold-amount, 0));

func gold_change(new_gold):
	var tween = get_node("MoneyPanel/Tween");
	tween.interpolate_method(self, "set_gold", gold, new_gold, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed");
	gold = new_gold;

func set_gold(new_gold):
	$MoneyPanel/money_text.bbcode_text = ""
	$MoneyPanel/money_text.append_bbcode("[center]"+str(int(new_gold))+"[/center]")

func _on_Button_pressed():
	if not settings_spawned:
		var panel = SettingsPanel.instance();
		self.add_child(panel);
		settings_spawned = true
		return; # Replace with function body.

# Called when the node enters the scene tree for the first time.
func _ready():
	var order_card_list = OrderCardList.instance();
	self.add_child(order_card_list);
	return; # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


