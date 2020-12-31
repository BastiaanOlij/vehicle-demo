extends Spatial

# Thanks to Game Endeavor for giving me some ideas on how to make this script simpler.
# Watch his video on the topic of scene changes here:
# https://www.youtube.com/watch?v=_4_DVbZwmYc

var resource_queue = null
var loading_environment = null

var current_world = null
onready var ftb = $FadeToBlack
onready var player_node = $Player
onready var ls = $Loading_scene
onready var ws = $World_scene
onready var wenv = $World_environment

func get_player_node():
	return player_node

func load_environment(new_environment):
	wenv.environment = new_environment

func load_world(scene_to_load):
	if !ftb or !player_node or !ls or !ws or !wenv:
		print("Environment not setup correctly")
		return
	
	# start loading our scene
	resource_queue.queue_resource(scene_to_load)
	
	# fade to black
	ftb.is_faded = true
	yield(ftb, "finished_fading")
	
	# switch to loading scene
	if current_world:
		current_world.disconnect("load_world", self, "load_world")
		ws.remove_child(current_world)
		current_world.queue_free()
		current_world = null
	ws.visible = false
	
	# center player
	$Player.transform = Transform()
	
	# Show our loading scene
	load_environment(loading_environment)
	ls.visible = true
	
	# fade to transparent
	ftb.is_faded = false
	yield(ftb, "finished_fading")
	
	# now we wait until our scene is loaded
	var new_world = resource_queue.get_resource(scene_to_load)
	if new_world:
		current_world = new_world.instance()
		
		# fade to black
		ftb.is_faded = true
		yield(ftb, "finished_fading")
		
		# and setup
		ls.visible = false 
		ws.add_child(current_world)
		current_world.connect("load_world", self, "load_world")
		current_world.init_world(self)
		ws.visible = true
		
		# fade to transparent
		ftb.is_faded = false
		yield(ftb, "finished_fading")
	else:
		# need to do some sort of error handling...
		pass

# Called when the node enters the scene tree for the first time.
func _ready():
	resource_queue = get_node('/root/resource_queue')
	loading_environment = preload("res://scenes/loading/black_environment.tres")
	
	# init our resource queue
	resource_queue.start()
	
	# and load our starting scene
	# load_world("res://scenes/tracks/track_01/track.tscn")
	load_world("res://scenes/tracks/test/track.tscn")
