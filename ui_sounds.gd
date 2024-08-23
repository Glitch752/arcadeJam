extends Node


var playback:AudioStreamPlaybackPolyphonic


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Create an audio player
	var player = AudioStreamPlayer.new()
	add_child(player)

	# Create a polyphonic stream so we can play sounds directly from it
	var stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32
	player.stream = stream
	player.play()
	# Get the polyphonic playback stream to play sounds
	playback = player.get_stream_playback()

	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node:Node) -> void:
	if node is Button:
		# If the added node is a button we connect to its mouse_entered and pressed signals
		# and play a sound
		node.mouse_entered.connect(_play_hover)
		node.pressed.connect(_play_pressed)
		node.focus_entered.connect(_play_hover)


var _hover_sound = preload('res://assets/sounds/ui_hover.wav');
func _play_hover() -> void:
	playback.play_stream(_hover_sound, 0, 0, randf_range(0.9, 1.1))

var _press_sound = preload('res://assets/sounds/ui_click.wav');
func _play_pressed() -> void:
	playback.play_stream(_press_sound, 0, 0, randf_range(0.9, 1.1))
