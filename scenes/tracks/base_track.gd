extends Spatial

signal load_world(scene_to_load)

export (Environment) var environment = preload("res://default_env.tres")
var construct = null

func init_world(world_construct):
	construct = world_construct
	construct.load_environment(environment)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

