extends Panel

onready var backdrop_panel = $Backdrop;

onready var order_finished;
onready var orderfailed;
onready var coin_earned;
onready var coin_lost;

func remove_itself():
	get_parent().settings_spawned = false
	get_tree().paused = false;
	queue_free()
	
func _init(order_finished = 123, orderfailed = 10, coin_earned = 100, coin_lost = 20):
	self.order_finished = order_finished;
	self.orderfailed = orderfailed;
	self.coin_earned = coin_earned;
	self.coin_lost = coin_lost;
	pass;

func _ready():
	$Clap.stream.loop = false;
	$Clap.play();
	#get_tree().paused = true;
	$OrderFinishedText.bbcode_text = "[right]"+str(order_finished)+"[/right]";
	$OrderFailedText.bbcode_text = "[right]"+str(orderfailed)+"[/right]";
	$CoinEarnedText.bbcode_text = "[right]"+str(coin_earned)+"[/right]";
	$CoinLostText.bbcode_text = "[right]"+str(coin_lost)+"[/right]";
	#pass;
	


func _on_RestartButton_pressed():
	return get_tree().change_scene("res://scenes/Level1.tscn")
	pass # Replace with function body.


func _on_MainMenuButton_pressed():
	return get_tree().change_scene("res://scenes/MainMenu.tscn")
	pass # Replace with function body.
