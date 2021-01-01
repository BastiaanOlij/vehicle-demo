extends PopupDialog

onready var inputmap = get_node('/root/inputmap')

enum MAP {
	NONE,
	STEERING,
	THROTTLE,
	BRAKE,
	GEARUP,
	GEARDOWN
}

var map_input = MAP.NONE
var mapping_changed = false

func _input(event):
	if map_input == MAP.NONE:
		return
	
	var changed = false
	if event is InputEventJoypadMotion:
		if (abs(event.axis_value) > 0.5):
			# print("Mapping to device %d, axis %d (%f)" % [ event.device, event.axis, event.axis_value ])
			if map_input == MAP.STEERING:
				inputmap.steering_device = event.device
				inputmap.steering_axis = event.axis
				changed = true
			elif map_input == MAP.THROTTLE:
				inputmap.throttle_device = event.device
				inputmap.throttle_axis = event.axis
				changed = true
			elif map_input == MAP.BRAKE:
				inputmap.brake_device = event.device
				inputmap.brake_axis = event.axis
				changed = true
	elif event is InputEventJoypadButton:
		if event.is_pressed():
			# print("Mapping to device %d, button %d" % [ event.device, event.button_index ])
			if map_input == MAP.GEARUP:
				inputmap.gear_up_device = event.device
				inputmap.gear_up_button = event.button_index
				changed = true
			elif map_input == MAP.GEARDOWN:
				inputmap.gear_down_device = event.device
				inputmap.gear_down_button = event.button_index
				changed = true
	
	if changed:
		mapping_changed = true
		map_input = MAP.NONE
		$MapDialog.visible = false
		_update_mapping_display()
		
		get_tree().set_input_as_handled()

func _update_mapping_display():
	$VBoxContainer/Steering/Mapped.text = "Device %d, Axis %d" % [ inputmap.steering_device, inputmap.steering_axis ]
	$VBoxContainer/Throttle/Mapped.text = "Device %d, Axis %d" % [ inputmap.throttle_device, inputmap.throttle_axis ]
	$VBoxContainer/Throttle/Mode.select(inputmap.throttle_mode)
	$VBoxContainer/Throttle/Invert.pressed = inputmap.throttle_inverse
	$VBoxContainer/Brake/Mapped.text = "Device %d, Axis %d" % [ inputmap.brake_device, inputmap.brake_axis ]
	$VBoxContainer/Brake/Mode.select(inputmap.brake_mode)
	$VBoxContainer/Brake/Invert.pressed = inputmap.brake_inverse
	
	$VBoxContainer/GearUp/Mapped.text = "Device %d, Button %d" % [ inputmap.gear_up_device, inputmap.gear_up_button ]
	$VBoxContainer/GearDown/Mapped.text = "Device %d, Button %d" % [ inputmap.gear_down_device, inputmap.gear_down_button ]

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Throttle/Mode.add_item("0.0 to 1.0", 0)
	$VBoxContainer/Throttle/Mode.add_item("0.0 to -1.0", 1)
	$VBoxContainer/Throttle/Mode.add_item("-1.0 to 1.0", 2)
	
	$VBoxContainer/Brake/Mode.add_item("0.0 to 1.0", 0)
	$VBoxContainer/Brake/Mode.add_item("0.0 to -1.0", 1)
	$VBoxContainer/Brake/Mode.add_item("-1.0 to 1.0", 2)
	
	_update_mapping_display()

func _on_Settings_about_to_show():
	get_tree().paused = true

func _on_Settings_popup_hide():
	get_tree().paused = false

func _on_ClosePopup_pressed():
	if mapping_changed:
		inputmap.save_input_map()
	visible = false

func _on_Steering_Map_pressed():
	map_input = MAP.STEERING
	$MapDialog.popup_centered()

func _on_Throttle_Map_pressed():
	map_input = MAP.THROTTLE
	$MapDialog.popup_centered()

func _on_Throttle_Mode_item_selected(index):
	mapping_changed = true
	inputmap.throttle_mode = index

func _on_Throttle_Invert_pressed():
	mapping_changed = true
	inputmap.throttle_inverse = $VBoxContainer/Throttle/Invert.pressed

func _on_Brake_Map_pressed():
	map_input = MAP.BRAKE
	$MapDialog.popup_centered()

func _on_Brake_Mode_item_selected(index):
	mapping_changed = true
	inputmap.brake_mode = index

func _on_Brake_Invert_pressed():
	mapping_changed = true
	inputmap.brake_inverse = $VBoxContainer/Brake/Invert.pressed

func _on_GearUp_Map_pressed():
	map_input = MAP.GEARUP
	$MapDialog.popup_centered()

func _on_GearDown_Map_pressed():
	map_input = MAP.GEARDOWN
	$MapDialog.popup_centered()

func _on_CancelMap_pressed():
	map_input = MAP.NONE
	$MapDialog.visible = false





