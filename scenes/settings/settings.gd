extends Popup

var mapping_changed = false

func _on_map_dialog_mapping_changed():
	mapping_changed = true
	_update_mapping_display()

func _update_mapping_display():
	$MarginContainer/VBoxContainer/Steering/Mapped.text = "Device %d, Axis %d" % [ InputMapSettings.steering_device, InputMapSettings.steering_axis ]
	$MarginContainer/VBoxContainer/Throttle/Mapped.text = "Device %d, Axis %d" % [ InputMapSettings.throttle_device, InputMapSettings.throttle_axis ]
	$MarginContainer/VBoxContainer/Throttle/Mode.select(InputMapSettings.throttle_mode)
	$MarginContainer/VBoxContainer/Throttle/Invert.button_pressed = InputMapSettings.throttle_inverse
	$MarginContainer/VBoxContainer/Brake/Mapped.text = "Device %d, Axis %d" % [ InputMapSettings.brake_device, InputMapSettings.brake_axis ]
	$MarginContainer/VBoxContainer/Brake/Mode.select(InputMapSettings.brake_mode)
	$MarginContainer/VBoxContainer/Brake/Invert.button_pressed = InputMapSettings.brake_inverse
	
	$MarginContainer/VBoxContainer/GearUp/Mapped.text = "Device %d, Button %d" % [ InputMapSettings.gear_up_device, InputMapSettings.gear_up_button ]
	$MarginContainer/VBoxContainer/GearDown/Mapped.text = "Device %d, Button %d" % [ InputMapSettings.gear_down_device, InputMapSettings.gear_down_button ]

# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/VBoxContainer/Throttle/Mode.add_item("0.0 to 1.0", 0)
	$MarginContainer/VBoxContainer/Throttle/Mode.add_item("0.0 to -1.0", 1)
	$MarginContainer/VBoxContainer/Throttle/Mode.add_item("-1.0 to 1.0", 2)
	
	$MarginContainer/VBoxContainer/Brake/Mode.add_item("0.0 to 1.0", 0)
	$MarginContainer/VBoxContainer/Brake/Mode.add_item("0.0 to -1.0", 1)
	$MarginContainer/VBoxContainer/Brake/Mode.add_item("-1.0 to 1.0", 2)
	
	_update_mapping_display()

func _on_Settings_about_to_show():
	get_tree().paused = true

func _on_Settings_popup_hide():
	get_tree().paused = false

func _on_Steering_Map_pressed():
	$MapDialog.open(InputMapDialog.MAP.STEERING)

func _on_Throttle_Map_pressed():
	$MapDialog.open(InputMapDialog.MAP.THROTTLE)

func _on_Throttle_Mode_item_selected(index):
	mapping_changed = true
	InputMapSettings.throttle_mode = index

func _on_Throttle_Invert_pressed():
	mapping_changed = true
	InputMapSettings.throttle_inverse = $MarginContainer/VBoxContainer/Throttle/Invert.button_pressed

func _on_Brake_Map_pressed():
	$MapDialog.open(InputMapDialog.MAP.BRAKE)

func _on_Brake_Mode_item_selected(index):
	mapping_changed = true
	InputMapSettings.brake_mode = index

func _on_Brake_Invert_pressed():
	mapping_changed = true
	InputMapSettings.brake_inverse = $MarginContainer/VBoxContainer/Brake/Invert.button_pressed

func _on_GearUp_Map_pressed():
	$MapDialog.open(InputMapDialog.MAP.GEARUP)

func _on_GearDown_Map_pressed():
	$MapDialog.open(InputMapDialog.MAP.GEARDOWN)

func _on_close_requested():
	if mapping_changed:
		InputMapSettings.save_input_map()
