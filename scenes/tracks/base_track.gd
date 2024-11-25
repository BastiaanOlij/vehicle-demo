extends Node3D
class_name BaseTrack

signal load_world(scene_to_load)

var construct = null

func init_world(world_construct):
	construct = world_construct

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

