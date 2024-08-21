extends VehicleBody3D

const STEERING_ANGLE = 40; # In degrees
const TURNING_SPEED = 3.5; # How fast the wheels adjust to a new position. Higher numbers are faster.
const BASE_ENGINE_FORCE = 600; # The base engine force applied to every traction wheel individually

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$RacingOrbitCamera.set_active(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	steering = move_toward(
		steering,
		Input.get_axis("move_right", "move_left") * STEERING_ANGLE * PI / 180,
		delta * TURNING_SPEED
	);
	engine_force = Input.get_axis("move_back", "move_forward") * BASE_ENGINE_FORCE
