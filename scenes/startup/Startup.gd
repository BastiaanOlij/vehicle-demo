extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Desktop_pressed():
	var window : Window = get_window()

	if $Fullscreen.button_pressed:
		# set it as full screen
		window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
	else:
		# make it resizable
		window.mode = Window.MODE_WINDOWED
		window.unresizable = false

	get_tree().change_scene_to_file("res://scenes/constructs/desktop/construct-desktop.tscn")

func _on_TextureButton_pressed():
	if $Fullscreen.button_pressed:
		# set it as full screen
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
	else:
		# make it resizable
		get_window().unresizable = not (true)

	get_tree().change_scene_to_file("res://scenes/constructs/VR/construct-vr.tscn")
