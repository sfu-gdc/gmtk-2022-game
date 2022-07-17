extends Control
var SettingsPanel = preload("res://prefabs/SettingsPanel.tscn")

var settings_spawned := false

func _on_SettingsButton_pressed():
	if not settings_spawned:
		var panel = SettingsPanel.instance();
		get_tree().get_root().add_child(panel);
		settings_spawned = true
		
func _on_StartButton_pressed():
	return get_tree().change_scene("res://scenes/Level1.tscn")
