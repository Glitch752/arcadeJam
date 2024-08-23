extends VehicleBody3D

const STEERING_ANGLE = 40; # In degrees
const TURNING_SPEED = 3.5; # How fast the wheels adjust to a new position. Higher numbers are faster.
const BASE_ENGINE_FORCE = 600; # The base engine force applied to every traction wheel individually

const STEERING_ANGLE_RAD: float = float(STEERING_ANGLE) * PI / 180;

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$RacingOrbitCamera.set_active(true)

var engine_force_smooth := 0
var steering_smoother: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $"/root/LevelLogic".law_verification_running == true:
		steering = move_toward(steering, 0, delta * TURNING_SPEED);
		engine_force = 0
		return
	
	var left_right = clamp(
		Input.get_axis("move_right", "move_left") + -Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		-1, 1
	)
	var back_forward = clamp(
		Input.get_axis("move_back", "move_forward") + sqrt(
			Input.get_joy_axis(0, JOY_AXIS_LEFT_X) ** 2 + Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) ** 2
		) * -sign(Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)),
		-1, 1
	)
	
	steering = move_toward(
		steering,
		left_right * STEERING_ANGLE_RAD,
		delta * TURNING_SPEED
	);
	engine_force = back_forward * BASE_ENGINE_FORCE
	
	var last_engine_force = engine_force_smooth
	engine_force_smooth = move_toward(engine_force_smooth, engine_force, delta * BASE_ENGINE_FORCE)
	steering_smoother = move_toward(steering_smoother, steering, delta * STEERING_ANGLE_RAD * 2)
	$"AudioPlayer1".pitch_scale = \
		1 + abs(engine_force_smooth) / float(BASE_ENGINE_FORCE) + \
		abs(steering_smoother) / STEERING_ANGLE_RAD * 0.3
	$"AudioPlayer1".volume_db = -60 + 30 * pow(engine_force_smooth / float(BASE_ENGINE_FORCE), 0.3)


func _on_car_collider_body_entered(body):
	$"/root/LevelLogic".player_car_start_touching(body)
func _on_car_collider_body_exited(body):
	$"/root/LevelLogic".player_car_stop_touching(body)
