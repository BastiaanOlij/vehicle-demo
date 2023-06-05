@tool
extends MultiMeshInstance3D

class_name MultiAlongPath

@export var path : Path3D : set = set_path
@export var shift : Vector2 = Vector2(0.0, 0.0): set = set_shift_pressed

func set_path(new_path: Path3D):
	if path:
		path.disconnect("curve_changed", Callable(self, "_update_instances"))
	
	path = new_path
	if path and is_inside_tree():
		path.connect("curve_changed", Callable(self, "_update_instances"))

func set_shift_pressed(new_shift : Vector2):
	shift = new_shift
	if path and is_inside_tree():
		_update_instances()

func _update_instances():
	if !multimesh:
		return
	if !path:
		return
	if !path.curve:
		return
		
	var curve : Curve3D = path.curve
	var total_length = curve.get_baked_length()
	var spacing = total_length / multimesh.instance_count
	
	var offset_t : Transform3D = path.global_transform * global_transform.inverse()
	
	var offset = 0.0
	var pos = curve.sample_baked(offset)
	for i in range(0, multimesh.instance_count):
		var next_pos = curve.sample_baked(fmod(offset + 2.0, total_length))
		var up = curve.sample_baked_up_vector(offset)
		
		var forward = (next_pos - pos).normalized()
		var t : Transform3D
		
		t = t.looking_at(forward, up)
		t.origin = pos + (up * shift.y) + (t.basis.x * shift.x)
		
		t = t * offset_t
		
		multimesh.set_instance_transform(i, t)
		
		# next!
		offset = offset + spacing
		pos = next_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	if path and is_inside_tree():
		path.connect("curve_changed", Callable(self, "_update_instances"))
