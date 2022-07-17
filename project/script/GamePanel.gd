extends Control
var SettingsPanel = preload("res://prefabs/SettingsPanel.tscn")
var OrderCardList = preload("res://prefabs/OrderCardList.tscn")
var SummaryPanel = preload("res://prefabs/SummaryPanel.tscn")
var settings_spawned := false

var gold = 0;
var order_completed = 0;
var order_failed = 0;
var coin_earned = 0;
var coin_lost = 0;

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventKey and event.is_pressed() && event.scancode in [KEY_BRACKETLEFT, 125] ):
		gold_increase(100);
	if (event is InputEventKey and event.is_pressed() && event.scancode in [KEY_BRACKETRIGHT, 123]):
		gold_decrease(100);

func gold_increase(amount):
	order_completed+=1;
	coin_earned+=amount;
	gold_change(gold+amount);
	
func gold_decrease(amount):
	order_failed+=1;
	coin_lost+=amount;
	if (gold-amount < 0):
		coin_lost-=gold-amount;
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
		print("setting is comint~~")
		return; # Replace with function body.

# Called when the node enters the scene tree for the first time.
func _ready():
	var order_card_list = OrderCardList.instance();
	order_card_list.name = "OrderCardList"
	self.add_child(order_card_list);
	return; # Replace with function body.


func _on_GameTimer_timeout():
	self.find_node("GameTimerText").stop();
	get_tree().paused = true;
	var panel = SummaryPanel.instance();
	panel._setup(order_completed, order_failed, coin_earned, coin_lost);
	add_child(panel);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


