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
		"verify": _verifyOnRoad,
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
	return false
#endregion


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

var law_verification_running: bool = false
signal law_verification_signal

func _attempt_parking():
	if law_verification_running:
		return
	
	law_verification_running = true
	# This is super hacky, but it works for now ¯\_(ツ)_/¯
	var lawStatus = get_law_status()
	
	law_verification_signal.emit(["laws", lawStatus])
	var anyBroken := false
	var i := 0
	for law in lawStatus:
		law_verification_signal.emit(["law", {
			"index": i,
			"broken": law["broken"]
		}])
		i += 1
		if law["broken"]:
			print("Broke law ", law["name"], "!")
			anyBroken = true
		else:
			print("Law ", law["name"], " satisfied!")
			
		await get_tree().create_timer(1.2).timeout
	
	law_verification_signal.emit(["success", !anyBroken])
	
	await get_tree().create_timer(1).timeout
	
	law_verification_running = false



func reset_level_state():
	touching_other_cars.clear()
	law_verification_running = false
