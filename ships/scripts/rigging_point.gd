class_name RiggingPoint
extends Marker3D

@export var main_hull : bool = true
@export var only_receive : bool = false

var rigged_to_main_hull : bool = false

const thickness : float = 0.1
const max_angle : float = 30
const min_dot : float = cos(deg_to_rad(max_angle))

var connections : Array[RiggingPoint]


func _ready() -> void:
	var p = self
	while p != get_tree().root:
		p = p.get_parent_node_3d()
		var generator : ShipExteriorGenerator = p as ShipExteriorGenerator
		if generator:
			generator.rigging_points.append(self)
			break


func rig(points : Array[RiggingPoint]):
	if only_receive: return
	if main_hull and rigged_to_main_hull: return
	
	var best_point : RiggingPoint = null
	var best_score : float = 0
	
	for p in points:
		if p == self or p in connections: continue # dont duplicate connections
		if main_hull and !p.main_hull: continue # dont let mainhull send to hull parts
		
		var dot = (global_basis.z).dot((p.global_position - global_position).normalized())
		var dist = p.global_position.distance_to(global_position)
		#if dot > min_dot : continue
		
		#if (global_basis.z).dot(p.global_basis.z) > 0: continue # dont connect to obviously bad points
		
		var score = dot * (1.0/dist)
		
		if best_point == null or score > best_score:
			best_point = p
			best_score = score
	
	if best_point == null: return
	
	connections.append(best_point)
	best_point.connections.append(self)
	
	if main_hull: best_point.rigged_to_main_hull = true
	if best_point.main_hull: rigged_to_main_hull = true
	
	var rope = CSGBox3D.new()
	add_child(rope)
	rope.global_position = (global_position + best_point.global_position) / 2.0
	rope.size = Vector3(thickness, thickness, global_position.distance_to(best_point.global_position))
	rope.look_at(best_point.global_position)
