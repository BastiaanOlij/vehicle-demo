tool
extends EditorPlugin

const Utils = preload("res://addons/sketchfab/Utils.gd")

var main = preload("res://addons/sketchfab/Main.tscn").instance()

func _enter_tree():
	get_tree().set_meta("__editor_scale", _get_editor_scale())
	get_tree().set_meta("__editor_interface", get_editor_interface())
	get_editor_interface().get_editor_viewport().add_child(main)
	main.visible = false

func _exit_tree():
	get_editor_interface().get_editor_viewport().remove_child(main)

func has_main_screen():
	return true

func get_plugin_name():
	return "Sketchfab"

func get_plugin_icon():
	# Call _get_editor_scale() here as SceneTree is not instanced yet
	return Utils.create_texture_from_file(
		"res://addons/sketchfab/icon.png.noimport",
		_get_editor_scale() / 2.0)

func make_visible(visible):
	main.visible = visible

# WORKAROUND until there's access to editor scale for plugins
func _get_editor_scale():
	var settings = get_editor_interface().get_editor_settings()
	var display_scale = settings.get("interface/editor/display_scale")

	if display_scale == 0:
		var screen = OS.get_current_screen()
		return (2.0 if
			OS.get_screen_dpi(screen) >= 192 && OS.get_screen_size(screen).x > 2000
			else 1.0)
	elif display_scale == 1:
		return 0.75
	elif display_scale == 2:
		return 1.0
	elif display_scale == 3:
		return 1.25
	elif display_scale == 4:
		return 1.5
	elif display_scale == 5:
		return 1.75
	elif display_scale == 6:
		return 2.0
	else:
		return (settings.get("interface/editor/custom_display_scale") if
			settings.has_setting("interface/editor/custom_display_scale")
			else 1.0)
