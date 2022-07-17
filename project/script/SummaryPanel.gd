extends CanvasLayer

onready var backdrop_panel = $Backdrop;

onready var order_finished;
onready var orderfailed;
onready var coin_earned;
onready var coin_lost;

func remove_itself():
	get_parent().settings_spawned = false
	get_tree().paused = false;
	queue_free()
	
	
func _setup(order_finished = 123, orderfailed = 10, coin_earned = 100, coin_lost = 20):
	self.order_finished = order_finished;
	self.orderfailed = orderfailed;
	self.coin_earned = coin_earned;
	self.coin_lost = coin_lost;

func _ready():
	$Clap.stream.loop = false;
	$Clap.play();
	#get_tree().paused = true;
	$Panel/OrderFinishedText.bbcode_text = "[right]"+str(order_finished)+"[/right]";
	$Panel/OrderFailedText.bbcode_text = "[right]"+str(orderfailed)+"[/right]";
	$Panel/CoinEarnedText.bbcode_text = "[right]"+str(coin_earned)+"[/right]";
	$Panel/CoinLostText.bbcode_text = "[right]"+str(coin_lost)+"[/right]";
	#pass;
	


func _on_RestartButton_pressed():
	get_tree().paused = false;
	return get_tree().change_scene("res://scenes/Level1.tscn")
	pass # Replace with function body.


func _on_MainMenuButton_pressed():
	get_tree().paused = false;
	return get_tree().change_scene("res://prefabs/MainestMenu.tscn")
	pass # Replace with function body.
