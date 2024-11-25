extends Node3D

func set_dial(value):
	$SubViewport/DialFace.set_dial(deg_to_rad(value * 260.0))

func _ready():
	var material : ShaderMaterial = $Face.material_override
	if material:
		material.set_shader_parameter("face", $SubViewport.get_texture())
