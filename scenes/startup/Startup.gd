extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Desktop_pressed():
	get_tree().change_scene("res://scenes/constructs/desktop/construct-desktop.tscn")
	
	if $Fullscreen.pressed:
		# set it as full screen
		OS.window_fullscreen = true
	else:
		# make it resizable
		OS.window_resizable = true

func _on_TextureButton_pressed():
	get_tree().change_scene("res://scenes/constructs/VR/construct-vr.tscn")
	
	if $Fullscreen.pressed:
		# set it as full screen
		OS.window_fullscreen = true
	else:
		# make it resizable
		OS.window_resizable = true
