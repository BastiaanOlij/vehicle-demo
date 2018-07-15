tool
extends Path

export var track_width = 8.0 setget set_track_width, get_track_width
export var rail_distance = 1.0 setget set_rail_distance, get_rail_distance
export var post_distance = 1.0 setget set_post_distance, get_post_distance

var is_dirty = true

func set_track_width(new_width):
	if track_width != new_width:
		track_width = new_width
		is_dirty = true
		call_deferred("_update")

func get_track_width():
	return track_width

func set_rail_distance(new_dist):
	if rail_distance != new_dist:
		rail_distance = new_dist
		is_dirty = true
		call_deferred("_update")

func get_rail_distance():
	return rail_distance

func set_post_distance(new_dist):
	if post_distance != new_dist:
		post_distance = new_dist
		is_dirty = true
		call_deferred("_update")

func get_post_distance():
	return post_distance

func _update():
	if !is_dirty:
		return
	
	# how long is our track?
	var curve_length = curve.get_baked_length()
	
	# update our posts
	var post_count = floor(curve_length / post_distance)
	var real_post_dist = curve_length / post_count
	
	$Posts.multimesh.instance_count = post_count * 2
	
	for i in range(0, post_count):
		var t = Transform()
		var xf = Transform()
		var f = i * real_post_dist
		
		xf.origin = curve.interpolate_baked(f)
		var lookat = (curve.interpolate_baked(f + 0.1) - xf.origin).normalized()
		
		# for our rotation we need to take tilt into account but we'll add that later
		var up = Vector3(0.0, 1.0, 0.0)
		xf.basis.z = lookat
		xf.basis.x = lookat.cross(up).normalized()
		xf.basis.y = xf.basis.x.cross(lookat).normalized()
		
		var v = Vector3(track_width * 0.5 + rail_distance, 0.0, 0.0)
		
		t.basis = Basis()
		t.origin = xf.xform(-v)
		$Posts.multimesh.set_instance_transform(i, t)
		
		t.basis = Basis()
		t.origin = xf.xform(v)
		$Posts.multimesh.set_instance_transform(post_count + i, t)
		
	is_dirty = false

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("_update")

func _on_Path_curve_changed():
	is_dirty = true
	call_deferred("_update")
