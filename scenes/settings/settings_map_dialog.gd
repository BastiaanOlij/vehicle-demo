extends Popup
class_name InputMapDialog

signal mapping_changed

enum MAP {
	NONE,
	STEERING,
	THROTTLE,
	BRAKE,
	GEARUP,
	GEARDOWN
}

var map_input = MAP.NONE

func open(p_map_input: MAP):
	map_input = p_map_input
	popup_centered()

func _input(event):
	if map_input == MAP.NONE:
		return

	var changed = false
	if event is InputEventJoypadMotion:
		if (abs(event.axis_value) > 0.5):
			# print("Mapping to device %d, axis %d (%f)" % [ event.device, event.axis, event.axis_value ])
			if map_input == MAP.STEERING:
				InputMapSettings.steering_device = event.device
				InputMapSettings.steering_axis = event.axis
				changed = true
			elif map_input == MAP.THROTTLE:
				InputMapSettings.throttle_device = event.device
				InputMapSettings.throttle_axis = event.axis
				changed = true
			elif map_input == MAP.BRAKE:
				InputMapSettings.brake_device = event.device
				InputMapSettings.brake_axis = event.axis
				changed = true
	elif event is InputEventJoypadButton:
		if event.is_pressed():
			# print("Mapping to device %d, button %d" % [ event.device, event.button_index ])
			if map_input == MAP.GEARUP:
				InputMapSettings.gear_up_device = event.device
				InputMapSettings.gear_up_button = event.button_index
				changed = true
			elif map_input == MAP.GEARDOWN:
				InputMapSettings.gear_down_device = event.device
				InputMapSettings.gear_down_button = event.button_index
				changed = true
	
	if changed:
		map_input = MAP.NONE
		get_viewport().set_input_as_handled()

		emit_signal("mapping_changed")
		hide()

func _on_cancel_map_pressed():
	map_input = MAP.NONE
	hide()
