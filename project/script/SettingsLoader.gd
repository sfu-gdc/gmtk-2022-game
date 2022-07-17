extends Node
var settings_filepath = "user://settings.cfg"
var settings_file = ConfigFile.new();

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
			var val = settings_file.get_value(section, key, null);
			if val != null:
				_settings[section][key] = val; 
			
func _ready():
	load_settings();
	sync_music();
	
	# this is for sync key control
	sync_key_mapping();
	

func sync_music():
	# this will control the audio to mute or not
	load_settings();
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !_settings["audio"]["background_music"])
	
	# backward compatiable if the SFX bus is not available yet
	if (AudioServer.get_bus_index("SFX") != -1):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), !_settings["audio"]["sfx"])

func sync_key_mapping():
	#update the keymapping right here
	load_settings();
	print(_settings)
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
	
	sync_music();
	sync_key_mapping();
	
