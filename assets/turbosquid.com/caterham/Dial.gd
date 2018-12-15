extends Spatial

func set_dial(value):
	$Viewport/DialFace.set_dial(deg2rad(value * 260.0))
