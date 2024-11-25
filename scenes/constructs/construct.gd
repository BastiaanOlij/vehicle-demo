extends Node3D

# Thanks to Game Endeavor for giving me some ideas on how to make this script simpler.
# Watch his video on the topic of scene changes here:
# https://www.youtube.com/watch?v=_4_DVbZwmYc

@export var camera : Camera3D

var current_world = null
@onready var ftb = $FadeToBlack
@onready var player_node = $Player
@onready var ls = $Loading_scene
@onready var ws = $World_scene
@onready var loading_environment = preload("res://scenes/loading/black_environment.tres")

func get_player_node():
	return player_node

func load_world(scene_to_load):
	if !ftb or !player_node or !ls or !ws:
		print("Environment not setup correctly")
		return
	
	# fade to black
	ftb.is_faded = true
	await ftb.finished_fading
	
	# switch to loading scene
	if current_world:
		current_world.disconnect("load_world", Callable(self, "load_world"))
		ws.remove_child(current_world)
		current_world.queue_free()
		current_world = null
	ws.visible = false
	
	# center player
	$Player.transform = Transform3D()
	
	# Show our loading scene
	if camera:
		camera.environment = loading_environment
	ls.visible = true
	
	# fade to transparent
	ftb.is_faded = false
	await ftb.finished_fading
	
	# now we wait until our scene is loaded
	var new_world : PackedScene
	if ResourceLoader.has_cached(scene_to_load):
		# Load cached scene
		new_world = ResourceLoader.load(scene_to_load)
	else:
		# Start the loading in a thread
		ResourceLoader.load_threaded_request(scene_to_load)

		# Loop waiting for the scene to load
		while true:
			var progress := []
			var res := ResourceLoader.load_threaded_get_status(scene_to_load, progress)
			if res != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				break;

			# $LoadingScreen.progress = progress[0]
			await get_tree().create_timer(0.1).timeout

		# Get the loaded scene
		new_world = ResourceLoader.load_threaded_get(scene_to_load)

	if new_world:
		current_world = new_world.instantiate()
		
		# fade to black
		ftb.is_faded = true
		await ftb.finished_fading
		
		# and setup
		ls.visible = false 
		if camera:
			camera.environment = null
		ws.add_child(current_world)
		current_world.connect("load_world", Callable(self, "load_world"))
		current_world.init_world(self)
		ws.visible = true
		
		# fade to transparent
		ftb.is_faded = false
		await ftb.finished_fading
	else:
		# need to do some sort of error handling...
		pass

# Called when the node enters the scene tree for the first time.
func _ready():
	# and load our starting scene
	# load_world("res://scenes/tracks/track_01/track.tscn")
	load_world("res://scenes/tracks/test/track.tscn")

func _process(_delta : float):
	if Input.is_action_just_pressed("open_settings"):
		$Settings.popup_centered()
