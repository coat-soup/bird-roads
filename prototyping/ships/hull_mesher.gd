@tool
extends MeshInstance3D

@export_tool_button("generate mesh", "PrismMesh") var gen_button = generate_mesh
@export var segment_length : float = 3.0
@export var segment_depth : int = 5
@export var num_segments : int = 5
@export var hull_width : float = 9.0

var verts = PackedVector3Array()
var norms = PackedVector3Array()

func generate_mesh():
	print("generating mesh")
	
	generate_verts()
	
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh = arr_mesh


func generate_verts() -> PackedVector3Array:
	verts = PackedVector3Array()
	norms = PackedVector3Array()
	
	for side in [-1,1]:
		for s in range(num_segments):
			for d in range(segment_depth):
				verts.push_back(Vector3(s * segment_length, -d, side * hull_width * get_length_curve(s/float(num_segments)) * get_depth_curve(d/5.0)))
				verts.push_back(Vector3((s + 1) * segment_length, -d, side * hull_width * get_length_curve((s+1)/float(num_segments)) * get_depth_curve(d/5.0)))
				verts.push_back(Vector3((s + 1) * segment_length, -d-1, side * hull_width * get_length_curve((s+1)/float(num_segments)) * get_depth_curve((d+1)/5.0)))
				
				verts.push_back(Vector3(s * segment_length, -d, side * hull_width * get_length_curve(s/float(num_segments)) * get_depth_curve(d/5.0)))
				verts.push_back(Vector3((s + 1) * segment_length, -d-1, side * hull_width * get_length_curve((s+1)/float(num_segments)) * get_depth_curve((d+1)/5.0)))
				verts.push_back(Vector3(s * segment_length, -d-1, side * hull_width * get_length_curve(s/float(num_segments)) * get_depth_curve((d+1)/5.0)))
	
	return verts

func get_depth_curve(depth : float) -> float:
	return 1.0 - depth

func get_length_curve(length : float) -> float:
	#return 1.0
	print(length)
	return sin(length*PI)
