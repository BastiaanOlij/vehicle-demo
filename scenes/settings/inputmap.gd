extends Node

enum AXIS_MODE {
	ZERO_TO_ONE,
	ZERO_TO_MINUS_ONE,
	MINUS_ONE_TO_ONE
}

@export var deadzone : float = 0.01

@export var steering_device : int = 0
@export var steering_axis : int = 0

@export var throttle_device : int = 0
@export var throttle_axis : int = 3 # 7
@export var throttle_mode : AXIS_MODE = AXIS_MODE.ZERO_TO_MINUS_ONE
@export var throttle_inverse : bool = false

@export var brake_device : int = 0
@export var brake_axis : int = 3 # 6
@export var brake_mode : AXIS_MODE = AXIS_MODE.ZERO_TO_ONE
@export var brake_inverse : bool = false

@export var gear_up_device : int = 0
@export var gear_up_button : int = 5
var was_gear_up = false

@export var gear_down_device : int = 0
@export var gear_down_button : int = 4
var was_gear_down = false

func _ready():
	load_input_map()

func process_input(value: float, mode: int, inverse: bool) -> float:
	if mode == AXIS_MODE.ZERO_TO_ONE:
		value = clamp(value, 0.0, 1.0)
	elif mode == AXIS_MODE.ZERO_TO_MINUS_ONE:
		value = -clamp(value, -1.0, 0.0)
	
	if inverse:
		value = 1.0 - value
	
	if abs(value) < deadzone:
		value = 0.0
	
	return value

# Returns -1.0 when steering left, 0.0 when center and 1.0 when steering right.
func get_steering_input() -> float:
	var steering : float = Input.get_joy_axis(steering_device, steering_axis)
	
	# TODO apply our curve here
	
	return steering

func get_throttle_input() -> float:
	var throttle : float = Input.get_joy_axis(throttle_device, throttle_axis)
	
	return process_input(throttle, throttle_mode, throttle_inverse)

func get_brake_input() -> float:
	var brake : float = Input.get_joy_axis(brake_device, brake_axis)
	
	return process_input(brake, brake_mode, brake_inverse)

func get_shift_down() -> bool:
	if Input.is_joy_button_pressed(gear_down_device, gear_down_button):
		if !was_gear_down:
			was_gear_down = true
			return true
	else:
		was_gear_down = false
	return false

func get_shift_up() -> bool:
	if Input.is_joy_button_pressed(gear_up_device, gear_up_button):
		if !was_gear_up:
			was_gear_up = true
			return true
	else:
		was_gear_up = false
	return false

func load_input_map(filename = "user://inputmap.json"):
	var load_file = FileAccess.open(filename, FileAccess.READ)
	if load_file:
		var as_text = load_file.get_as_text()
		load_file.close()
		
		var test_json_conv = JSON.new()
		test_json_conv.parse(as_text)
		var data = test_json_conv.get_data()
		if data.has("Steering"):
			steering_device = data.Steering.device
			steering_axis = data.Steering.axis
		if data.has("Throttle"):
			throttle_device = data.Throttle.device
			throttle_axis = data.Throttle.axis
			throttle_mode = data.Throttle.mode
			throttle_inverse = data.Throttle.inverse == "yes"
		if data.has("Brake"):
			brake_device = data.Brake.device
			brake_axis = data.Brake.axis
			brake_mode = data.Brake.mode
			brake_inverse = data.Brake.inverse == "yes"
		if data.has("GearUp"):
			gear_up_device = data.GearUp.device
			gear_up_button = data.GearUp.button
		if data.has("GearDown"):
			gear_down_device = data.GearDown.device
			gear_down_button = data.GearDown.button

func save_input_map(filename = "user://inputmap.json"):
	var data = {
		"Steering": {
			"device": steering_device,
			"axis": steering_axis
		},
		"Throttle": {
			"device": throttle_device,
			"axis": throttle_axis,
			"mode": throttle_mode,
			"inverse": "yes" if throttle_inverse else "no"
		},
		"Brake": {
			"device": brake_device,
			"axis": brake_axis,
			"mode": brake_mode,
			"inverse": "yes" if brake_inverse else "no"
		},
		"GearUp": {
			"device": gear_up_device,
			"button": gear_up_button
		},
		"GearDown": {
			"device": gear_down_device,
			"button": gear_down_button
		}
	}
	
	var save_file = FileAccess.open(filename, FileAccess.WRITE)
	if save_file:
		var as_json = JSON.stringify(data)
		
		save_file.store_line(as_json)
		save_file.close()
