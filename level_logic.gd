extends Node

#region Parking laws
var parkingLaws: Array[Dictionary] = [
	{
		"name": "Don't touch other cars while parked.",
		"verify": _verify_touching_other_cars,
		"introduced": 1
	},
	{
		"name": "Don't touch other cars while parked.",
		"verify": _verify_touching_other_cars,
		"introduced": 1
	},
	{
		"name": "Don't touch other cars while parked.",
		"verify": _verify_touching_other_cars,
		"introduced": 1
	},
	{
		"name": "You must be on the road when parked.",
		"verify": _verifyOnRoad,
		"introduced": 2
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

func _verifyOnRoad() -> bool:
	return true
#endregion



func reset_level_state():
	touching_other_cars.clear()





func get_active_laws() -> Array[Dictionary]:
	if !get_tree().current_scene:
		return []
	
	var level = get_tree().current_scene.name.to_lower().replace("level", "").to_int()
	
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
	
	if event.is_action_released("reset"):
		get_tree().reload_current_scene()
		reset_level_state()
	
	if event.is_action_released("park"):
		_attempt_parking()

func _attempt_parking():
	# This is super hacky, but it works for now ¯\_(ツ)_/¯
	var lawStatus = get_law_status()
	
	for law in lawStatus:
		if law["broken"]:
			print("Broke law ", law["name"], "!")
		else:
			print("Law ", law["name"], " satisfied!")
		await get_tree().create_timer(0.3).timeout
