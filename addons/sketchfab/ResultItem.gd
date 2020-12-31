tool
extends MarginContainer

const SafeData = preload("res://addons/sketchfab/SafeData.gd")
const Utils = preload("res://addons/sketchfab/Utils.gd")

const ModelDialog = preload("res://addons/sketchfab/ModelDialog.tscn")

onready var user_name = find_node("UserName")
onready var model_name = find_node("ModelName")
onready var image = find_node("Image")

var data

var dialog

func set_data(data):
	self.data = data

func _enter_tree():
	rect_min_size *= get_tree().get_meta("__editor_scale")

func _ready():
	if !data:
		return

	model_name.text = SafeData.string(data, "name")

	var user = SafeData.dictionary(data, "user")
	user_name.text = "by %s" % SafeData.string(user, "displayName")

	var thumbnails = SafeData.dictionary(data, "thumbnails")
	var images = SafeData.array(thumbnails, "images")
	image.url = Utils.get_best_size_url(images, self.image.max_size, SafeData)

func _on_Button_pressed():
	dialog = ModelDialog.instance()
	dialog.set_uid(SafeData.string(data, "uid"))
	add_child(dialog)
	dialog.connect("popup_hide", self, "_on_dialog_hide")
	dialog.popup_centered()

func _on_dialog_hide():
	remove_child(dialog)
