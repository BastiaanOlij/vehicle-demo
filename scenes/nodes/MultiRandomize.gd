@tool
extends Node3D

@export var area_size = Vector2(10.0, 10.0): set = set_area_size
@export var trunk : Mesh: set = set_trunk
@export var leaves : Mesh: set = set_leaves
@export var tree_count : int = 100: set = set_tree_count
@export var tree_rotation : Vector3 : set = set_tree_rotation
@export var min_scale : float = 1.0: set = set_min_scale
@export var max_scale : float = 1.0: set = set_max_scale

var is_dirty = true
var trunk_multimesh : MultiMesh
var leaves_multimesh : MultiMesh

func set_area_size(new_area_size : Vector2):
	area_size = new_area_size
	if !is_dirty:
		is_dirty = true
		call_deferred("_update_multimeshes")

func set_trunk(new_trunk : Mesh):
	trunk = new_trunk
	if !is_dirty:
		is_dirty = true
		call_deferred("_update_multimeshes")

func set_leaves(new_leaves : Mesh):
	leaves = new_leaves
	if !is_dirty:
		is_dirty = true
		call_deferred("_update_multimeshes")

func set_tree_count(new_count : int):
	tree_count = new_count
	if !is_dirty:
		is_dirty = true
		call_deferred("_update_multimeshes")

func set_tree_rotation(new_rotation : Vector3):
	tree_rotation = new_rotation
	if !is_dirty:
		is_dirty = true
		call_deferred("_update_multimeshes")

func set_min_scale(new_scale : float):
	min_scale = new_scale
	if !is_dirty:
		is_dirty = true
		call_deferred("_update_multimeshes")

func set_max_scale(new_scale : float):
	max_scale = new_scale
	if !is_dirty:
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
	r.x = deg_to_rad(r.x)
	r.y = deg_to_rad(r.y)
	r.z = deg_to_rad(r.z)
	
	for i in range(0, tree_count):
		var t = Transform3D()
		var s = randf_range(min_scale, max_scale)
		
		t.basis = Basis.from_euler(r).rotated(Vector3.UP, randf_range(0.0, 2.0 * PI))
		t.origin.x = randf_range(-area_size.x, area_size.x)
		t.origin.z = randf_range(-area_size.y, area_size.y)
		t = t.scaled(Vector3(s, s, s))
		
		trunk_multimesh.set_instance_transform(i, t)
		leaves_multimesh.set_instance_transform(i, t)

# Called when the node enters the scene tree for the first time.
func _ready():
	trunk_multimesh = MultiMesh.new()
	trunk_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	var trunk_instance = MultiMeshInstance3D.new()
	trunk_instance.multimesh = trunk_multimesh
	add_child(trunk_instance)
	
	leaves_multimesh = MultiMesh.new()
	leaves_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	var leaves_instance = MultiMeshInstance3D.new()
	leaves_instance.multimesh = leaves_multimesh
	add_child(leaves_instance)
	
	is_dirty = true
	call_deferred("_update_multimeshes")
