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
		"background_music": false,
		"sfx": false
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

func load_settings():
	var error = settings_file.load(settings_filepath);
	if error != OK:
		_on_SaveButton_pressed();
		settings_file.load(settings_filepath);
		
	for section in _settings.keys():
		for key in _settings[section]:
			_settings[section][key] = settings_file.get_value(section, key, null);
			
	$TabContainer/Controls/Player1Label/MoveForward/KeyButton/Label.text = OS.get_scancode_string(_settings["controls"]["player1_up"])
	$TabContainer/Controls/Player1Label/MoveDownward/KeyButton/Label.text = OS.get_scancode_string(_settings["controls"]["player1_down"])
	$TabContainer/Controls/Player1Label/MoveLeft/KeyButton/Label.text = OS.get_scancode_string(_settings["controls"]["player1_left"])
	$TabContainer/Controls/Player1Label/MoveRight/KeyButton/Label.text = OS.get_scancode_string(_settings["controls"]["player1_right"])
	$TabContainer/Controls/Player1Label/Interact/KeyButton/Label.text = OS.get_scancode_string(_settings["controls"]["player1_activate"])
	$TabContainer/Controls/Player1Label/PickupDrop/KeyButton/Label.text = OS.get_scancode_string(_settings["controls"]["player1_pick"])
	sync_key_mapping();

func _ready():
	#pass;
	load_settings();
	
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
	queue_free();
	pass # Replace with function body.


func sync_key_mapping():
	#update the keymapping right here
	for key in _settings['controls'].keys():
		#_settings['controls'][key] = settings_file.get_value('controls', key, null);
		var list = InputMap.get_action_list( _control_keymapping[key] );
		for i in list:
			if i is InputEventKey:
				# remove the previous register physical key mapping
				if (i.scancode > 0 || i.physical_scancode > 0):
				#if current_scancode == _settings["controls"][key_listening]:
					InputMap.action_erase_event( _control_keymapping[key], i )
		var e = InputEventKey.new();
		e.set_scancode(_settings['controls'][key])
		InputMap.action_add_event(_control_keymapping[key], e);

func _on_SaveButton_pressed():
	for section in _settings.keys():
		for key in _settings[section]:
			settings_file.set_value(section, key, _settings[section][key]);
	settings_file.save(settings_filepath);
	
	
	sync_key_mapping();
	queue_free();
	pass # Replace with function body.;


func _on_KeyButton_pressed(settingkeyword:String, keymapname:String, origin:String):
	key_listening = settingkeyword;
	keymap_listening = keymapname;
	var target = "TabContainer/Controls/Player1Label/"+origin+"/KeyButton/Label"
	text_to_update = get_node(target);
	backdrop_panel.show();
	pass # Replace with function body.
