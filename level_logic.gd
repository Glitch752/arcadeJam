extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#region Level logic
var levels: Array[Dictionary] = [
	{ "scene": preload("res://levels/level1.tscn"), "name": "Tutorial" },
	{ "scene": preload("res://levels/level2.tscn"), "name": "Real parking" },
	{ "scene": preload("res://levels/level3.tscn"), "name": "No space" },
	{ "scene": preload("res://levels/level4.tscn"), "name": "What does \"blocking\" entail?" }
];
var current_level: int = -1;

func get_level_data() -> Array[Dictionary]:
	if !FileAccess.file_exists("user://levelsCompleted.save"):
		var levels_completed_file = FileAccess.open("user://levelsCompleted.save", FileAccess.WRITE)
		levels_completed_file.store_32(0)
		levels_completed_file.close()
	
	var levels_completed_file = FileAccess.open("user://levelsCompleted.save", FileAccess.READ)
	var last_level_completed: int = levels_completed_file.get_32() - 1
	
	var i = 0
	var level_data: Array[Dictionary] = []
	for level in levels:
		level_data.append({
			"name": level["name"],
			"complete": i <= last_level_completed,
			"laws": parkingLaws.filter(func(law): return law["introduced"] <= i).size()
		})
		i += 1
	
	return level_data

func load_from_menu():
	var level_data = get_level_data()
	var i = 0
	for level in level_data:
		if !level["complete"]:
			load_level(i)
			return
		i += 1
	load_level(0)

func get_current_level() -> int:
	return current_level

func load_level(level_index: int):
	print("Loading level ", level_index)
	
	if level_index < 0 || level_index >= levels.size():
		print("Tried to load an out-of-range level: ", level_index, "!")
		return
	
	var level = levels[level_index]["scene"]
	get_tree().change_scene_to_packed(level)
	reset_level_state()
	current_level = level_index

func load_next_level():
	if !FileAccess.file_exists("user://levelsCompleted.save"):
		var levels_completed_file = FileAccess.open("user://levelsCompleted.save", FileAccess.WRITE)
		levels_completed_file.store_32(1)
		levels_completed_file.close()
	
	var levels_completed_file = FileAccess.open("user://levelsCompleted.save", FileAccess.READ_WRITE)
	var last_level_completed: int = levels_completed_file.get_32() - 1
	if last_level_completed < current_level + 1:
		levels_completed_file.seek(0)
		levels_completed_file.store_32(current_level + 1)
	
	if current_level + 1 >= levels.size():
		# You finished the game!
		# TODO: A win screen or something
		load_menu()
		return
	
	load_level(current_level + 1)

func load_menu():
	get_tree().change_scene_to_file("res://menu/mainMenu.tscn")
	current_level = -1

func reset_level_state():
	touching_other_cars.clear()
	law_verification_running = false

func level_result_continue(broke_laws: bool):
	if broke_laws:
		get_tree().reload_current_scene()
		reset_level_state()
	else:
		load_next_level()
	
	law_verification_signal.emit(["reset"])
#endregion

#region Parking laws
var parkingLaws: Array[Dictionary] = [
	{
		"name": "Don't touch other cars while parked.",
		"verify": _verify_touching_other_cars,
		"introduced": 0
	},
	{
		"name": "Park near the edge of the road.",
		"verify": _verify_near_road_edge,
		"introduced": 1
	},
];

var touching_other_cars: Array[String] = []
func _verify_touching_other_cars() -> bool:
	return touching_other_cars.is_empty()
func player_car_start_touching(other: Node3D):
	if other.find_parent("OtherVehicles") && !touching_other_cars.has(other.name):
		touching_other_cars.append(other.name)
func player_car_stop_touching(other: Node3D):
	if other.find_parent("OtherVehicles") && touching_other_cars.has(other.name):
		touching_other_cars = touching_other_cars.filter(func(name): return name != other.name)

func _verify_near_road_edge() -> bool:
	var scene = get_tree().current_scene
	if !scene:
		return false
	
	var road_edge_area: Area3D = scene.find_child("RoadEdgeArea", false, false)
	var player: Node3D = scene.find_child("sedan", false, false)
	
	if !road_edge_area || !player:
		return false
	
	return road_edge_area.overlaps_body(player)
#endregion

func get_active_laws() -> Array[Dictionary]:
	var level = get_current_level()
	if level == -1:
		return []
	
	var activeLaws: Array[Dictionary] = []
	for law in parkingLaws:
		if law.get("introduced") <= level:
			activeLaws.append(law)
	
	return activeLaws

func get_law_status() -> Array[Dictionary]:
	var active_laws = get_active_laws()
	var law_status: Array[Dictionary] = []
	
	for law in active_laws:
		law_status.append({
			"broken": !law["verify"].call(),
			"name": law["name"]
		})
	
	return law_status

func _unhandled_input(event):
	# This is super hacky, but it works for now ¯\_(ツ)_/¯
	if !get_tree().current_scene || !get_tree().current_scene.name.to_lower().begins_with("level"):
		return
	
	if law_verification_running:
		return
	
	if event.is_action_released("reset"):
		get_tree().reload_current_scene()
		reset_level_state()
	
	if event.is_action_released("park"):
		_attempt_parking()

var law_verification_running: bool = false
signal law_verification_signal

func _attempt_parking():
	if law_verification_running:
		return
	
	law_verification_running = true
	# This is super hacky, but it works for now ¯\_(ツ)_/¯
	var lawStatus = get_law_status()
	
	law_verification_signal.emit(["laws", lawStatus])
	var brokenLaws: Array[String] = []
	var i := 0
	for law in lawStatus:
		law_verification_signal.emit(["law", {
			"index": i,
			"broken": law["broken"]
		}])
		i += 1
		if law["broken"]:
			print("Broke law ", law["name"], "!")
			brokenLaws.append(law["name"])
		else:
			print("Law ", law["name"], " satisfied!")
			
		await get_tree().create_timer(0.8).timeout
	
	law_verification_signal.emit(["finish", {
		"success": brokenLaws.is_empty(),
		"brokenLaws": brokenLaws
	}])
