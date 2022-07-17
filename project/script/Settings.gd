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
		"player1_throw": KEY_F
	},
	"control_type": {
		"player1_up": 0,
		"player1_down": 0,
		"player1_left": 0,
		"player1_right": 0,
		"player1_pick": 0,
		"player1_activate": 0,
		"player1_throw": 0
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
	"player1_throw": "throw"
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

	$"TabContainer/P1 Controls/Player1Label/MoveForward/KeyButton/Label".text = OS.get_scancode_string(_settings["controls"]["player1_up"])
	$"TabContainer/P1 Controls/Player1Label/MoveDownward/KeyButton/Label".text = OS.get_scancode_string(_settings["controls"]["player1_down"])
	$"TabContainer/P1 Controls/Player1Label/MoveLeft/KeyButton/Label".text = OS.get_scancode_string(_settings["controls"]["player1_left"])
	$"TabContainer/P1 Controls/Player1Label/MoveRight/KeyButton/Label".text = OS.get_scancode_string(_settings["controls"]["player1_right"])
	$"TabContainer/P1 Controls/Player1Label/Interact/KeyButton/Label".text = OS.get_scancode_string(_settings["controls"]["player1_activate"])
	$"TabContainer/P1 Controls/Player1Label/PickupDrop/KeyButton/Label".text = OS.get_scancode_string(_settings["controls"]["player1_pick"])

func _ready():
	get_tree().paused = true;
	load_settings();
	#pass;
	
# _unhandled_input no work
func _input(event: InputEvent) -> void:
	print(event)
	if(event is InputEventJoypadButton):
		print(event.button_index)
		print(event.pressed)
		
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
	for section in _settings.keys():
		for key in _settings[section]:
			settings_file.set_value(section, key, _settings[section][key]);
	settings_file.save(settings_filepath);
	
	SettingsLoader.sync_music();
	SettingsLoader.sync_key_mapping();
	remove_itself();


func _on_KeyButton_pressed(settingkeyword:String, keymapname:String, origin:String):
	key_listening = settingkeyword;
	keymap_listening = keymapname;
	var target = "TabContainer/P1 Controls/Player1Label/"+origin+"/KeyButton/Label"
	text_to_update = get_node(target);
	backdrop_panel.show();


func _on_CheckBox_toggled(button_pressed, _origin_label, target_settings):
	_settings["audio"][target_settings] = button_pressed;
