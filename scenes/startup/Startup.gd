extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Desktop_pressed():
	get_tree().change_scene_to_file("res://scenes/constructs/desktop/construct-desktop.tscn")
	
	if $Fullscreen.button_pressed:
		# set it as full screen
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
	else:
		# make it resizable
		get_window().unresizable = false
		get_window().mode = Window.MODE_WINDOWED

func _on_TextureButton_pressed():
	get_tree().change_scene_to_file("res://scenes/constructs/VR/construct-vr.tscn")
	
	if $Fullscreen.button_pressed:
		# set it as full screen
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
	else:
		# make it resizable
		get_window().unresizable = not (true)
