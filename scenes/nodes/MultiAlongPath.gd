tool
extends MultiMeshInstance

class_name MultiAlongPath

export (NodePath) var path = null setget set_path
export (Vector2) var shift = Vector2(0.0, 0.0) setget set_shift
var path_node : Path = null

func set_path(new_path: NodePath):
	if path_node:
		path_node.disconnect("curve_changed", self, "_update_instances")
	
	path = new_path
	path_node = null
	if path and is_inside_tree():
		path_node = get_node(path)
		if path_node:
			path_node.connect("curve_changed", self, "_update_instances")

func set_shift(new_shift : Vector2):
	shift = new_shift
	if path_node and is_inside_tree():
		_update_instances()

func _update_instances():
	if !multimesh:
		return
	if !path_node:
		return
	if !path_node.curve:
		return
		
	var curve : Curve3D = path_node.curve
	var total_length = curve.get_baked_length()
	var spacing = total_length / multimesh.instance_count
	
	var offset_t : Transform = path_node.global_transform * global_transform.inverse()
	
	var offset = 0.0
	var pos = curve.interpolate_baked(offset)
	for i in range(0, multimesh.instance_count):
		var next_pos = curve.interpolate_baked(fmod(offset + 2.0, total_length))
		var up = curve.interpolate_baked_up_vector(offset)
		
		var forward = (next_pos - pos).normalized()
		var t : Transform
		
		t = t.looking_at(forward, up)
		t.origin = pos + (up * shift.y) + (t.basis.x * shift.x)
		
		t = t * offset_t
		
		multimesh.set_instance_transform(i, t)
		
		# next!
		offset = offset + spacing
		pos = next_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	set_path(path)
