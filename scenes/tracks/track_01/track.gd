extends "res://scenes/tracks/base_track.gd"

func init_world(world_construct):
	super.init_world(world_construct)
	
	$Car/Driver.remote_path = world_construct.get_node("Player").get_path()
