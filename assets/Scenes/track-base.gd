@tool
extends Path3D

@export var track_width = 8.0: get = get_track_width, set = set_track_width
@export var lower_ground_width = 12.0: get = get_lower_ground_width, set = set_lower_ground_width
@export var rail_distance = 1.0: get = get_rail_distance, set = set_rail_distance
@export var post_distance = 1.0: get = get_post_distance, set = set_post_distance

var is_dirty = true

func set_track_width(new_width):
	if track_width != new_width:
		track_width = new_width
		if !is_dirty:
			is_dirty = true
			call_deferred("_update")

func get_track_width():
	return track_width

func set_lower_ground_width(new_width):
	if lower_ground_width != new_width:
		lower_ground_width = new_width
		if !is_dirty:
			is_dirty = true
			call_deferred("_update")

func get_lower_ground_width():
	return lower_ground_width

func set_rail_distance(new_dist):
	if rail_distance != new_dist:
		rail_distance = new_dist
		if !is_dirty:
			is_dirty = true
			call_deferred("_update")

func get_rail_distance():
	return rail_distance

func set_post_distance(new_dist):
	if post_distance != new_dist:
		post_distance = new_dist
		if !is_dirty:
			is_dirty = true
			call_deferred("_update")

func get_post_distance():
	return post_distance

func _update():
	if !is_dirty:
		return
	
	# Fix start and end tilt
	curve.set_point_tilt(0, deg_to_rad(90.0))
	curve.set_point_tilt(curve.get_point_count() - 1, 0.0)
	
	# how long is our track?
	var curve_length = curve.get_baked_length()
	
	###################################################################################
	# update our track
	var track_half_width = track_width * 0.5
	var ground_half_width = lower_ground_width * 0.5
	
	var track = $Road.polygon
	track.set(0, Vector2(-track_half_width, 0.0))
	track.set(1, Vector2(-track_half_width, -0.1))
	track.set(2, Vector2( track_half_width, -0.1))
	track.set(3, Vector2( track_half_width, 0.0))
	$Road.polygon = track
	
	var ground = $Ground.polygon
	ground.set(1, Vector2( track_half_width + 2.0, -0.1))
	ground.set(0, Vector2(-track_half_width - 2.0, -0.1))
	ground.set(2, Vector2( lower_ground_width, -4.01))
	ground.set(3, Vector2( lower_ground_width + 0.1, -4.1))
	ground.set(4, Vector2(-lower_ground_width - 0.1, -4.1))
	ground.set(5, Vector2(-lower_ground_width, -4.0))
	$Ground.polygon = ground
	
	###################################################################################
	# update our rails
	var rail_position = track_half_width + rail_distance
	
	var rail = $"Rail-L".polygon
	rail.set(0, Vector2(rail_position, 0.5))
	rail.set(1, Vector2(rail_position - 0.05, 0.47))
	rail.set(2, Vector2(rail_position - 0.05, 0.43))
	rail.set(3, Vector2(rail_position, 0.4))
	rail.set(4, Vector2(rail_position, 0.55))
	rail.set(5, Vector2(rail_position - 0.05, 0.32))
	rail.set(6, Vector2(rail_position - 0.05, 0.28))
	rail.set(7, Vector2(rail_position, 0.25))
	rail.set(8, Vector2(rail_position + 0.05, 0.25))
	rail.set(9, Vector2(rail_position + 0.05, 0.5))
	$"Rail-L".polygon = rail
	
	rail = $"Rail-R".polygon
	rail.set(0, Vector2(-rail_position, 0.5))
	rail.set(1, Vector2(-rail_position + 0.05, 0.47))
	rail.set(2, Vector2(-rail_position + 0.05, 0.43))
	rail.set(3, Vector2(-rail_position, 0.4))
	rail.set(4, Vector2(-rail_position, 0.55))
	rail.set(5, Vector2(-rail_position + 0.05, 0.32))
	rail.set(6, Vector2(-rail_position + 0.05, 0.28))
	rail.set(7, Vector2(-rail_position, 0.25))
	rail.set(8, Vector2(-rail_position - 0.05, 0.25))
	rail.set(9, Vector2(-rail_position - 0.05, 0.5))
	$"Rail-R".polygon = rail
	
	###################################################################################
	# update our posts
	var post_count = floor(curve_length / post_distance)
	var real_post_dist = curve_length / post_count
	
	$Posts.multimesh.instance_count = post_count * 2
	
	for i in range(0, post_count):
		var t = Transform3D()
		var xf = Transform3D()
		var f = i * real_post_dist
		
		xf.origin = curve.sample_baked(f)
		var lookat = (curve.sample_baked(f + 0.1) - xf.origin).normalized()
		
		# for our rotation we need to take tilt into account but we'll add that later
		var up = Vector3(0.0, 1.0, 0.0)
		xf.basis.z = lookat
		xf.basis.x = lookat.cross(up).normalized()
		xf.basis.y = xf.basis.x.cross(lookat).normalized()
		
		var v = Vector3(rail_position, 0.0, 0.0)
		
		t.basis = Basis()
		t.origin = xf * (-v)
		$Posts.multimesh.set_instance_transform(i, t)
		
		t.basis = Basis()
		t.origin = xf * (v)
		$Posts.multimesh.set_instance_transform(post_count + i, t)
	
	###################################################################################
	# update our collision
	
	var collision = $CollisionShape3D.polygon
	collision.set(0, Vector2(-rail_position, 0.0))
	collision.set(1, Vector2( rail_position, 0.0))
	collision.set(2, Vector2( rail_position, 5.0))
	collision.set(3, Vector2( rail_position + 3.0, 5.0))
	collision.set(4, Vector2( rail_position + 3.0, -1.0))
	collision.set(5, Vector2(-rail_position - 3.0, -1.0))
	collision.set(6, Vector2(-rail_position - 3.0, 5.0))
	collision.set(7, Vector2(-rail_position, 5.0))
	$CollisionShape3D.polygon=collision
	
	is_dirty = false

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("_update")

func _on_Path_curve_changed():
	if !is_dirty:
		is_dirty = true
		call_deferred("_update")
