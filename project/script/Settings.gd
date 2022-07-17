extends Panel
var settings_filepath = "user://settings.cfg"
var settings_file = ConfigFile.new();
onready var backdrop_panel = $Backdrop;

# this is the string variable for storing the corresponding key that is currently listening
var key_listening = null;

# this is the string corresponding to the keymap define in global
var keymap_listening = null;

# this is the target text label to update the latest key map
var text_to_update = null;

var _settings = {
	"audio": {
		"background_music": true,
		"sfx": true
	},
	"controls": {
		"player1_up": KEY_W,
		"player1_down": KEY_S,
		"player1_left": KEY_A,
		"player1_right": KEY_D,
		"player1_pick": KEY_Q,
		"player1_activate": KEY_E,
		"player1_throw": KEY_F,
		
		"player2_up": KEY_UP,
		"player2_down": KEY_DOWN,
		"player2_left": KEY_LEFT,
		"player2_right": KEY_RIGHT,
		"player2_pick": KEY_L,
		"player2_activate": KEY_K,
		"player2_throw": KEY_M
	},
	"control_type": {
		"player1_up": 0,
		"player1_down": 0,
		"player1_left": 0,
		"player1_right": 0,
		"player1_pick": 0,
		"player1_activate": 0,
		"player1_throw": 0,
		
		"player2_up": 0,
		"player2_down": 0,
		"player2_left": 0,
		"player2_right": 0,
		"player2_pick": 0,
		"player2_activate": 0,
		"player2_throw": 0
	}
};

# this is dictionary for mapping to global keymapping
var _control_keymapping = {
	"player1_up": "player_up",
	"player1_down": "player_down",
	"player1_left": "player_left",
	"player1_right": "player_right",
	"player1_pick": "pick",
	"player1_activate": "activate",
	"player1_throw": "throw",
	
	"player2_up": "player2_up",
	"player2_down": "player2_down",
	"player2_left": "player2_left",
	"player2_right": "player2_right",
	"player2_pick": "player2_pick",
	"player2_activate": "player2_activate",
	"player2_throw": "player2_throw"
}

func remove_itself():
	get_parent().settings_spawned = false
	get_tree().paused = false;
	queue_free()

func load_settings():
	var error = settings_file.load(settings_filepath);
	if error != OK:
		_on_SaveButton_pressed();
		settings_file.load(settings_filepath);
		
	for section in _settings.keys():
		for key in _settings[section]:
			_settings[section][key] = settings_file.get_value(section, key, null);
	
	$TabContainer/Audio/MusicLabel/CheckBox.pressed = _settings["audio"]["background_music"]
	$TabContainer/Audio/SFXLabel/CheckBox.pressed = _settings["audio"]["sfx"]
	
	for p in 2:
		var i = str(p+1)
		if _settings["control_type"]["player"+i+"_up"] == 0:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/MoveForward/KeyButton/Label").text = OS.get_scancode_string(_settings["controls"]["player"+i+"_up"])
		elif _settings["control_type"]["player"+i+"_up"] == 1:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/MoveForward/KeyButton/Label").text = Input.get_joy_button_string(_settings["controls"]["player"+i+"_up"])
		
		if _settings["control_type"]["player"+i+"_down"] == 0:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/MoveDownward/KeyButton/Label").text = OS.get_scancode_string(_settings["controls"]["player"+i+"_down"])
		elif _settings["control_type"]["player"+i+"_down"] == 1:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/MoveDownward/KeyButton/Label").text = Input.get_joy_button_string(_settings["controls"]["player"+i+"_down"])

		if _settings["control_type"]["player"+i+"_left"] == 0:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/MoveLeft/KeyButton/Label").text = OS.get_scancode_string(_settings["controls"]["player"+i+"_left"])
		elif _settings["control_type"]["player"+i+"_left"] == 1:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/MoveLeft/KeyButton/Label").text = Input.get_joy_button_string(_settings["controls"]["player"+i+"_left"])
		
		if _settings["control_type"]["player"+i+"_right"] == 0:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/MoveRight/KeyButton/Label").text = OS.get_scancode_string(_settings["controls"]["player"+i+"_right"])
		elif _settings["control_type"]["player"+i+"_right"] == 1:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/MoveRight/KeyButton/Label").text = Input.get_joy_button_string(_settings["controls"]["player"+i+"_right"])
		
		if _settings["control_type"]["player"+i+"_activate"] == 0:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/Interact/KeyButton/Label").text = OS.get_scancode_string(_settings["controls"]["player"+i+"_activate"])
		elif _settings["control_type"]["player"+i+"_activate"] == 1:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/Interact/KeyButton/Label").text = Input.get_joy_button_string(_settings["controls"]["player"+i+"_activate"])

		if _settings["control_type"]["player"+i+"_pick"] == 0:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/PickupDrop/KeyButton/Label").text = OS.get_scancode_string(_settings["controls"]["player"+i+"_pick"])
		elif _settings["control_type"]["player"+i+"_pick"] == 1:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/PickupDrop/KeyButton/Label").text = Input.get_joy_button_string(_settings["controls"]["player"+i+"_pick"])

		if _settings["control_type"]["player"+i+"_throw"] == 0:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/Throw/KeyButton/Label").text = OS.get_scancode_string(_settings["controls"]["player"+i+"_throw"])
		elif _settings["control_type"]["player"+i+"_throw"] == 1:
			get_node("TabContainer/P"+i+" Controls/Player"+i+"Label/Throw/KeyButton/Label").text = Input.get_joy_button_string(_settings["controls"]["player"+i+"_throw"])

func _ready():
	get_tree().paused = true;
	load_settings();
	#pass;
	
# _unhandled_input no work
func _input(event: InputEvent) -> void:
	if key_listening == null:
		return;
	
	if(event is InputEventJoypadButton and event.is_pressed()):
		# check to make sure the key is not being occupied
		_settings['controls'][key_listening] = event.button_index;
		_settings['control_type'][key_listening] = 1; # InputEventJoypadButton
		text_to_update.text = Input.get_joy_button_string(event.button_index);
		text_to_update = null;
		key_listening = null;
		keymap_listening = null;
		backdrop_panel.hide();
	elif (event is InputEventKey and event.is_pressed()):
		print("setting to 0")
		# check to make sure the key is not being occupied
		_settings['controls'][key_listening] = event.scancode;
		_settings['control_type'][key_listening] = 0; # InputEventKey
		text_to_update.text = OS.get_scancode_string(event.scancode);
		text_to_update = null;
		key_listening = null;
		keymap_listening = null;
		backdrop_panel.hide();
	
	get_tree().set_input_as_handled()

func _on_CancelButton_pressed():
	remove_itself();
	pass # Replace with function body.

func _on_SaveButton_pressed():
	print(_settings)
	for section in _settings.keys():
		for key in _settings[section]:
			settings_file.set_value(section, key, _settings[section][key]);
	settings_file.save(settings_filepath)
	
	SettingsLoader.sync_music();
	SettingsLoader.sync_key_mapping();
	remove_itself();


func _on_KeyButton_pressed(settingkeyword:String, keymapname:String, origin:String, player:int):
	key_listening = settingkeyword;
	keymap_listening = keymapname;
	var target = "TabContainer/P"+str(player)+" Controls/Player"+str(player)+"Label/"+origin+"/KeyButton/Label"
	text_to_update = get_node(target);
	backdrop_panel.show();


func _on_CheckBox_toggled(button_pressed, _origin_label, target_settings):
	_settings["audio"][target_settings] = button_pressed;
