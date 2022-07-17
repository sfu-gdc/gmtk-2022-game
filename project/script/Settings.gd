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
		"player1_activate": KEY_E
	}
};

# this is dictionary for mapping to global keymapping
var _control_keymapping = {
	"player1_up": "player_up",
	"player1_down": "player_down",
	"player1_left": "player_left",
	"player1_right": "player_right",
	"player1_pick": "pick",
	"player1_activate": "activate"
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

	$TabContainer/Controls/Player1Label/MoveForward/KeyButton/Label.text = OS.get_scancode_string(_settings["controls"]["player1_up"])
	$TabContainer/Controls/Player1Label/MoveDownward/KeyButton/Label.text = OS.get_scancode_string(_settings["controls"]["player1_down"])
	$TabContainer/Controls/Player1Label/MoveLeft/KeyButton/Label.text = OS.get_scancode_string(_settings["controls"]["player1_left"])
	$TabContainer/Controls/Player1Label/MoveRight/KeyButton/Label.text = OS.get_scancode_string(_settings["controls"]["player1_right"])
	$TabContainer/Controls/Player1Label/Interact/KeyButton/Label.text = OS.get_scancode_string(_settings["controls"]["player1_activate"])
	$TabContainer/Controls/Player1Label/PickupDrop/KeyButton/Label.text = OS.get_scancode_string(_settings["controls"]["player1_pick"])

func _ready():
	get_tree().paused = true;
	load_settings();
	#pass;
	
func _unhandled_input(event: InputEvent) -> void:
	if key_listening == null:
		return;
	if (event is InputEventKey and event.is_pressed()):
		# check to make sure the key is not being occupied
		_settings['controls'][key_listening] = event.scancode;
		text_to_update.text = OS.get_scancode_string(event.scancode);
		text_to_update = null;
		key_listening = null;
		keymap_listening = null;
		backdrop_panel.hide();


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
	pass # Replace with function body.;


func _on_KeyButton_pressed(settingkeyword:String, keymapname:String, origin:String):
	key_listening = settingkeyword;
	keymap_listening = keymapname;
	var target = "TabContainer/Controls/Player1Label/"+origin+"/KeyButton/Label"
	text_to_update = get_node(target);
	backdrop_panel.show();
	pass # Replace with function body.


func _on_CheckBox_toggled(button_pressed, _origin_label, target_settings):
	_settings["audio"][target_settings] = button_pressed;
	pass # Replace with function body.
