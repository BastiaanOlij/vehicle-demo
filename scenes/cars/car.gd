extends VehicleBody3D

############################################################
# Steering

@export var MAX_STEER_ANGLE = 30
@export var SPEED_STEER_ANGLE = 10
@export var MAX_STEER_SPEED = 120.0
@export var MAX_STEER_INPUT = 90.0
@export var STEER_SPEED = 1.0

@onready var max_steer_angle_rad = deg_to_rad(MAX_STEER_ANGLE)
@onready var speed_steer_angle_rad = deg_to_rad(SPEED_STEER_ANGLE)
@onready var max_steer_input_rad = deg_to_rad(MAX_STEER_INPUT)
@export  var steer_curve : Curve

var steer_target = 0.0
var steer_angle = 0.0

############################################################
# Speed and drive direction

@export var MAX_ENGINE_FORCE = 700.0
@export var MAX_BRAKE_FORCE = 50.0

@export var gear_ratios : Array = [ 2.69, 2.01, 1.59, 1.32, 1.13, 1.0 ] 
@export var reverse_ratio : float = -2.5
@export var final_drive_ratio : float = 3.38
@export var max_engine_rpm : float = 8000.0
@export var power_curve : Curve

var current_gear = 0 # -1 reverse, 0 = neutral, 1 - 6 = gear 1 to 6.
var clutch_position : float = 1.0 # 0.0 = clutch engaged
var current_speed_mps = 0.0
@onready var last_pos = position

var gear_shift_time = 0.3
var gear_timer = 0.0

func get_speed_kph():
	return current_speed_mps * 3600.0 / 1000.0

# calculate the RPM of our engine based on the current velocity of our car
func calculate_rpm() -> float:
	# if we are in neutral, no rpm
	if current_gear == 0:
		return 0.0
	
	var wheel_circumference : float = 2.0 * PI * $right_rear.wheel_radius
	var wheel_rotation_speed : float = 60.0 * current_speed_mps / wheel_circumference
	var drive_shaft_rotation_speed : float = wheel_rotation_speed * final_drive_ratio
	if current_gear == -1:
		# we are in reverse
		return drive_shaft_rotation_speed * -reverse_ratio
	elif current_gear <= gear_ratios.size():
		return drive_shaft_rotation_speed * gear_ratios[current_gear - 1]
	else:
		return 0.0

############################################################
# Input

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process_gear_inputs(delta : float):
	if gear_timer > 0.0:
		gear_timer = max(0.0, gear_timer - delta)
		clutch_position = 0.0
	else:
		if InputMapSettings.get_shift_down() and current_gear > -1:
			current_gear = current_gear - 1
			gear_timer = gear_shift_time
			clutch_position = 0.0
		elif InputMapSettings.get_shift_up() and current_gear < gear_ratios.size():
			current_gear = current_gear + 1
			gear_timer = gear_shift_time
			clutch_position = 0.0
		else:
			clutch_position = 1.0

func _process(delta : float):
	_process_gear_inputs(delta)
	
	var speed = get_speed_kph()
	var rpm = calculate_rpm()
	
	var info = 'Speed: %.0f, RPM: %.0f (gear: %d)'  % [ speed, rpm, current_gear ]
	
	$Info.text = info

func _physics_process(delta):
	# how fast are we going in meters per second?
	current_speed_mps = (position - last_pos).length() / delta
	
	# get our joystick inputs
	var steer_val = InputMapSettings.get_steering_input()
	var throttle_val = InputMapSettings.get_throttle_input()
	var brake_val = InputMapSettings.get_brake_input()
	
	var rpm = calculate_rpm()
	var rpm_factor = clamp(rpm / max_engine_rpm, 0.0, 1.0)
	var power_factor = power_curve.sample_baked(rpm_factor)
	
	if current_gear == -1:
		engine_force = clutch_position * throttle_val * power_factor * reverse_ratio * final_drive_ratio * MAX_ENGINE_FORCE
	elif current_gear > 0 and current_gear <= gear_ratios.size():
		engine_force = clutch_position * throttle_val * power_factor * gear_ratios[current_gear - 1] * final_drive_ratio * MAX_ENGINE_FORCE
	else:
		engine_force = 0.0
	
	brake = brake_val * MAX_BRAKE_FORCE
	
	$brake_lights.visible = brake_val > 0.1
	$reverse_lights.visible = current_gear == -1
	
	var max_steer_speed = MAX_STEER_SPEED * 1000.0 / 3600.0
	var steer_speed_factor = clamp(current_speed_mps / max_steer_speed, 0.0, 1.0)

	if (abs(steer_val) < 0.05):
		steer_val = 0.0
	elif steer_curve:
		if steer_val < 0.0:
			steer_val = -steer_curve.sample_baked(-steer_val)
		else:
			steer_val = steer_curve.sample_baked(steer_val)
	
	steer_angle = steer_val * lerp(max_steer_angle_rad, speed_steer_angle_rad, steer_speed_factor)
	steering = -steer_angle
	
	$interior/steering.rotation.z = steer_val * max_steer_input_rad
	$wings/left_wing.rotation.y = -steer_angle
	$wings/right_wing.rotation.y = -steer_angle
	
	# remember where we are
	last_pos = position
