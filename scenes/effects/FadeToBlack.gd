extends ColorRect

signal finished_fading

export var is_faded = false setget set_is_faded, get_is_faded
var is_ready = false

func set_is_faded(new_value: bool):
	if is_faded == new_value:
		# already set correctly, we emit our signal to make sure our process continues
		if is_ready:
			call_deferred("emit_signal", "finished_fading")
		
		return
	
	is_faded = new_value
	if is_ready:
		if is_faded:
			$AnimationPlayer.play("FadeToBlack")
		else:
			$AnimationPlayer.play("FadeToAlpha")

func _ready():
	# default our UI to our settings
	color = Color(0.0, 0.0, 0.0, 1.0)
	visible = is_faded
	
	is_ready = true

func get_is_faded():
	return is_faded

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("finished_fading")
