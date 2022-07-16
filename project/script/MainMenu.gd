extends Node2D
var SettingsPanel = preload("res://prefabs/SettingsPanel.tscn")

func _on_SettingsButton_pressed():
	var panel = SettingsPanel.instance();
	get_tree().get_root().add_child(panel);
	pass # Replace with function body.

func _on_StartButton_pressed():
	return get_tree().change_scene("res://scenes/Level1.tscn")
	 # Replace with function body.
