extends Node

#region Parking laws
var parkingLaws: Array[Dictionary] = [
	{
		"name": "Don't touch other cars while parked.",
		"verify": _verifyTouchingOtherCars,
		"introduced": 1
	},
	{
		"name": "You must be on the road when parked.",
		"verify": _verifyOnRoad,
		"introduced": 2
	},
];

func _verifyTouchingOtherCars() -> bool:
	return true

func _verifyOnRoad() -> bool:
	return true
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
