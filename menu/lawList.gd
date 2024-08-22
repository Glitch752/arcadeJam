extends Control

const LAW_LIST_UPDATE_INTERVAL = 0.25; # In seconds

var law_update_timer := Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	law_update_timer.one_shot = false
	law_update_timer.autostart = true
	law_update_timer.wait_time = LAW_LIST_UPDATE_INTERVAL
	law_update_timer.connect("timeout", _update_laws)
	add_child(law_update_timer)

var broken_law_label_settings = load("res://menu/brokenLawLabelSettings.tres")
var unbroken_law_label_settings = load("res://menu/unbrokenLawLabelSettings.tres")

var previous_law_list_length := 0
func _update_laws():
	var lawStatus: Array[Dictionary] = $"/root/LevelLogic".get_law_status()
	if previous_law_list_length != lawStatus.size():
		var children = $"LawList".get_children()
		for child in children:
			$"LawList".remove_child(child)
		for law in lawStatus:
			var label = Label.new()
			label.text = "- " + law["name"]
			if law["broken"]:
				label.label_settings = broken_law_label_settings
			else:
				label.label_settings = unbroken_law_label_settings
			$"LawList".add_child(label)
