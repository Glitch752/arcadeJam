extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/PlayButton.grab_focus()

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://levels/level1.tscn")

var settingsScene = preload("res://menu/settingsMenu.tscn").instantiate()
func _on_settings_button_pressed():
	get_tree().root.add_child(settingsScene)
	get_tree().root.remove_child(self)

func _on_quit_button_pressed():
	get_tree().quit()
