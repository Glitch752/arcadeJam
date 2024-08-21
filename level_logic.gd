extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	# This is super hacky, but it works for now ¯\_(ツ)_/¯
	if !get_tree().current_scene || !get_tree().current_scene.name.to_lower().begins_with("level"):
		return
	
	if event.is_action("reset"):
		get_tree().reload_current_scene()
