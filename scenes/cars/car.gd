extends VehicleBody

############################################################
# Behaviour values

export var MAX_ENGINE_FORCE = 700.0
export var MAX_BRAKE_FORCE = 50.0
export var MAX_STEER_ANGLE = 30
export var MAX_STEER_INPUT = 450.0

export var steer_speed = 1.0

onready var max_steer_angle_rad = deg2rad(MAX_STEER_ANGLE)
onready var max_steer_input_rad = deg2rad(MAX_STEER_INPUT)

var steer_target = 0.0
var steer_angle = 0.0

############################################################
# Speed and drive direction

var current_speed_mps = 0.0
onready var last_pos = translation

func get_speed_kph():
	return current_speed_mps * 3600.0 / 1000.0

############################################################
# Gear data

export (Array) var gear_ratios = [ 2.69, 2.01, 1.59, 1.32, 1.13, 1.0 ] 
export (float) var reverse_ratio = -2.5
export (float) var final_drive = 3.38
export (float) var max_engine_rpm = 8000.0
export (Curve) var power_curve = null
export (float) var gear_shift_time = 0.5

var selected_gear = 1 # -1 = reverse, 0 = neutral, 1+ = gear
var gear_shift_timer = 0.0

func get_engine_rpm() -> float:
	# if we're in neutral, or we've lost traction, we use our previous RPM + input
	if selected_gear == 0:
		return 0.0
	
	var wheel_size : float= 2.0 * PI * $right_rear.wheel_radius
	var wheel_rotation_speed : float= 60.0 * current_speed_mps / wheel_size
	
	var result : float = wheel_rotation_speed * final_drive ## drive shaft speed
	if selected_gear == -1:
		result = result * -reverse_ratio
	else:
		result = result * gear_ratios[selected_gear - 1]
	
	return result 

############################################################
# Input

export var joy_steering = JOY_ANALOG_LX
export var steering_mult = -1.0
export var joy_throttle = JOY_ANALOG_R2
export var throttle_mult = 1.0
export var joy_brake = JOY_ANALOG_L2
export var brake_mult = 1.0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

var measure_0_100 : bool = true
var time_0_100 : float = 0.0
var measure_0_160 : bool = true
var time_0_160 : float = 0.0

var rpm : float = 0.0
var rpm_factor : float = 0.0
var max_power : float = 0.0

var max_power_value : float = 0.0
var max_power_at_rev : float = 0.0

func _process(delta):
	if gear_shift_timer == 0.0:
		if Input.is_action_just_pressed("shift_down") and selected_gear > -1:
			selected_gear = selected_gear - 1
			gear_shift_timer = gear_shift_time
		elif Input.is_action_just_pressed("shift_up") and selected_gear < gear_ratios.size():
			selected_gear = selected_gear + 1
			gear_shift_timer = gear_shift_time
	
	var speed = get_speed_kph()
	
	$Speedo.set_dial(speed / 280.0)
	$RPMDial.set_dial(rpm / max_engine_rpm)
	
	if speed < 0.1:
		measure_0_100 = true
		time_0_100 = 0
		measure_0_160 = true
		time_0_160 = 0
	else:
		if measure_0_100:
			if speed > 100.0:
				measure_0_100 = false
			else:
				time_0_100 += delta
		
		if measure_0_160:
			if speed > 160.0:
				measure_0_160 = false
			else:
				time_0_160 += delta
	
	var info = 'Speed: %.0f, gear: %d, rpm: %.0f (%.3f) -> %0.3f\nmax power @ rpm: %.0f -> %0.3f\n'  % [ speed, selected_gear, rpm, rpm_factor, max_power, max_power_at_rev, max_power_value ]
	info += '0 - 100 (60mph): %0.2f\n' % [ time_0_100 ]
	info += '0 - 160 (100mph): %0.2f\n' % [ time_0_160 ]
	
	$Info.text = info

func _physics_process(delta):
	# how fast are we going in meters per second?
	current_speed_mps = (translation - last_pos).length() / delta
	
	# get our joystick inputs
	var steer_val = steering_mult * Input.get_joy_axis(0, joy_steering)
	# var throttle_val = throttle_mult * (1.0 - ((Input.get_joy_axis(0, joy_throttle) + 1.0) / 2.0))
	# var brake_val = brake_mult * (1.0 - ((Input.get_joy_axis(0, joy_brake) + 1.0) / 2.0)) 
	var throttle_val = throttle_mult * Input.get_joy_axis(0, joy_throttle)
	var brake_val = brake_mult * Input.get_joy_axis(0, joy_brake)
	
	if (throttle_val < 0.0):
		throttle_val = 0.0
	
	if (brake_val < 0.0):
		brake_val = 0.0
	
	# overrules for keyboard
	if Input.is_action_pressed("ui_up"):
		throttle_val = 1.0
	if Input.is_action_pressed("ui_down"):
		brake_val = 1.0
	if Input.is_action_pressed("ui_left"):
		steer_val = 1.0
	elif Input.is_action_pressed("ui_right"):
		steer_val = -1.0
	
	rpm = get_engine_rpm()
	if gear_shift_timer > 0.0:
		max_power = 0
		gear_shift_timer = max(gear_shift_timer - delta, 0.0)
	else:
		if (throttle_val == 0.0 and brake_val == 0.0 and current_speed_mps < 3.0):
			# if no throttle input, brake lightly
			brake_val = 0.1
		rpm_factor = clamp(rpm / max_engine_rpm, 0.1, 1.0)
		max_power = power_curve.interpolate_baked(rpm_factor)
		
		if max_power > max_power_value:
			max_power_value = max_power
			max_power_at_rev = rpm
		
		if selected_gear == -1:
			max_power = max_power * reverse_ratio
		elif selected_gear == 0:
			max_power = 0.0
		else:
			max_power = max_power * gear_ratios[selected_gear - 1]
	
	throttle_val = throttle_val * max_power * final_drive * MAX_ENGINE_FORCE
	brake_val = brake_val * MAX_BRAKE_FORCE
	
	engine_force = throttle_val
	brake = brake_val
	
	$brake_lights.visible = brake_val > 0.1
	$reverse_lights.visible = selected_gear == -1
	
	steer_angle = steer_val * max_steer_angle_rad
	steering = steer_angle
	
	$interior/steering.rotation.z = -steer_val * max_steer_input_rad
	$wings/left_wing.rotation.y = steer_angle
	$wings/right_wing.rotation.y = steer_angle
	
	# remember where we are
	last_pos = translation
