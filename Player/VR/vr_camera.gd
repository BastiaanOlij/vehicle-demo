extends ARVROrigin

export var max_distance = 0.3
var reset_time = 2.0
var alpha = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var interface = ARVRServer.find_interface("OpenVR")
	if interface and interface.initialize():
		get_viewport().arvr = true
		get_viewport().hdr = false

func _process(delta):
	# check if our reset is pressed
	if Input.is_action_pressed("center_hmd"):
		if reset_time > 0.0:
			reset_time -= delta
			if reset_time <= 0.0:
				ARVRServer.center_on_hmd(ARVRServer.RESET_BUT_KEEP_TILT, false)
	else:
		# reset our reset time
		reset_time = 2.0
	
	# show/hide/adjust our sphere if we're outside of our playing space
	var distance = $ARVRCamera.translation.length()
	if distance > max_distance:
		alpha += delta
		if alpha > 1.0:
			alpha = 1.0
		$CenterSphere.get_surface_material(0).set_shader_param("alpha", alpha)
		$CenterSphere.visible = true
	elif alpha > 0.0:
		alpha -= delta
		if alpha < 0.0:
			alpha = 0.0
			$CenterSphere.visible = false
		else:
			$CenterSphere.get_surface_material(0).set_shader_param("alpha", alpha)
			$CenterSphere.visible = true
	$CenterSphere.translation = $ARVRCamera.translation
	