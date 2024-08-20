extends VehicleBody3D

const STEERING_ANGLE = 0.8; # In radians; roughly 45deg
const TURNING_SPEED = 1.5; # How fast the wheels adjust to a new position. Higher numbers are faster.
const BASE_ENGINE_FORCE = 150; # The base engine force applied to every traction wheel individually

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	steering = move_toward(steering, Input.get_axis("ui_right", "ui_left") * STEERING_ANGLE, delta * TURNING_SPEED);
	engine_force = Input.get_axis("ui_down", "ui_up") * BASE_ENGINE_FORCE
