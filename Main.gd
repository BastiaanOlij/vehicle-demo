extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var speed = $Car/Car.get_speed_kph()
	$Speed.text = ("%0.2f" % speed) + " km/h"
