extends "res://scenes/constructs/construct.gd"

@export var max_distance = 0.3
var reset_time = 2.0
var alpha = 1.0
var was_reset = false

@onready var camera = $Player/XROrigin3D/XRCamera3D
@onready var msg_sphere = $Player/XROrigin3D/MsgSphere

# Called when the node enters the scene tree for the first time.
func _ready():
	var interface = XRServer.find_interface("OpenXR")
	if interface and interface.initialize():
		# yes we're in VR :)
		get_viewport().arvr = true
		
		# turn off vsync
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if (false) else DisplayServer.VSYNC_DISABLED)
		
		# change our physics fps
		Engine.physics_ticks_per_second = 90

func _process(delta):
	# show/hide/adjust our sphere if we're outside of our playing space
	var distance = camera.position.length()
	if distance > max_distance:
		alpha += delta
		if alpha > 1.0:
			alpha = 1.0
		msg_sphere.get_surface_override_material(0).set_shader_parameter("alpha", alpha)
		msg_sphere.visible = true
	elif alpha > 0.0:
		alpha -= delta
		if alpha < 0.0:
			alpha = 0.0
			msg_sphere.visible = false
		else:
			msg_sphere.get_surface_override_material(0).set_shader_parameter("alpha", alpha)
			msg_sphere.visible = true
	msg_sphere.position = camera.position
	
	# Align our sphere with where we are looking
	if was_reset:
		msg_sphere.rotation.y = camera.rotation.y
		was_reset = false
	elif msg_sphere.visible:
		var rotation_delta = camera.rotation.y - msg_sphere.rotation.y
		if rotation_delta < -PI:
			rotation_delta += 2 * PI
		elif rotation_delta > PI:
			rotation_delta -= 2 * PI
		msg_sphere.rotation.y += rotation_delta * delta
	
	# check if our reset is pressed
	if Input.is_action_pressed("center_hmd"):
		if reset_time > 0.0:
			reset_time -= delta
			if reset_time <= 0.0:
				XRServer.center_on_hmd(XRServer.RESET_BUT_KEEP_TILT, false)
				was_reset = true
	else:
		# reset our reset time
		reset_time = 2.0
