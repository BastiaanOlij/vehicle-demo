tool
extends Spatial

export var area_size = Vector2(10.0, 10.0) setget set_area_size
export (Mesh) var trunk = null setget set_trunk
export (Mesh) var leaves = null setget set_leaves
export (int) var tree_count = 100 setget set_tree_count
export (Vector3) var tree_rotation setget set_tree_rotation
export (float) var min_scale = 1.0 setget set_min_scale
export (float) var max_scale = 1.0 setget set_max_scale

var is_dirty = true
var trunk_multimesh : MultiMesh
var leaves_multimesh : MultiMesh

func set_area_size(new_area_size : Vector2):
	area_size = new_area_size
	is_dirty = true
	call_deferred("_update_multimeshes")

func set_trunk(new_trunk : Mesh):
	trunk = new_trunk
	is_dirty = true
	call_deferred("_update_multimeshes")

func set_leaves(new_leaves : Mesh):
	leaves = new_leaves
	is_dirty = true
	call_deferred("_update_multimeshes")

func set_tree_count(new_count : int):
	tree_count = new_count
	is_dirty = true
	call_deferred("_update_multimeshes")

func set_tree_rotation(new_rotation : Vector3):
	tree_rotation = new_rotation
	is_dirty = true
	call_deferred("_update_multimeshes")

func set_min_scale(new_scale : float):
	min_scale = new_scale
	is_dirty = true
	call_deferred("_update_multimeshes")

func set_max_scale(new_scale : float):
	max_scale = new_scale
	is_dirty = true
	call_deferred("_update_multimeshes")

func _update_multimeshes():
	if !trunk_multimesh:
		return
	if !leaves_multimesh:
		return
	
	if !is_dirty:
		return
	
	is_dirty = false
	trunk_multimesh.instance_count = tree_count
	trunk_multimesh.mesh = trunk
	leaves_multimesh.instance_count = tree_count
	leaves_multimesh.mesh = leaves
	if tree_count == 0:
		return
	
	var r = tree_rotation
	r.x = deg2rad(r.x)
	r.y = deg2rad(r.y)
	r.z = deg2rad(r.z)
	
	for i in range(0, tree_count):
		var t = Transform()
		var scale = rand_range(min_scale, max_scale)
		
		t.basis = Basis(r).rotated(Vector3.UP, rand_range(0.0, 2.0 * PI))
		t.origin.x = rand_range(-area_size.x, area_size.x)
		t.origin.z = rand_range(-area_size.y, area_size.y)
		t = t.scaled(Vector3(scale, scale, scale))
		
		trunk_multimesh.set_instance_transform(i, t)
		leaves_multimesh.set_instance_transform(i, t)

# Called when the node enters the scene tree for the first time.
func _ready():
	trunk_multimesh = MultiMesh.new()
	trunk_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	var trunk_instance = MultiMeshInstance.new()
	trunk_instance.multimesh = trunk_multimesh
	add_child(trunk_instance)
	
	leaves_multimesh = MultiMesh.new()
	leaves_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	var leaves_instance = MultiMeshInstance.new()
	leaves_instance.multimesh = leaves_multimesh
	add_child(leaves_instance)
	
	is_dirty = true
	call_deferred("_update_multimeshes")
