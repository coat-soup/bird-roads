class_name NavigationNode
extends Node3D

@export var connections : Array[NavigationNode]
var grid_pos : Vector3i

@export var cover_directions : Array[Vector3]


func try_add_connection(nodes : Array[NavigationNode], dims : Vector3i, pos : Vector3i, step_height : float) -> bool:
	if pos.x < 0 or pos.x >= dims.x or pos.y < 0 or pos.y >= dims.y or pos.z < 0 or pos.z >= dims.z: return false
	
	var node = nodes[pos.y * (dims.x * dims.z) + pos.z * dims.x + pos.x]
	
	if node == self or connections.has(node) or not node: return false
	if abs(node.global_position.y - global_position.y) > step_height: return false
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, node.global_position, Util.layer_mask([1]))
	var results = space_state.intersect_ray(query)
	if len(results) > 0: return false
	
	connections.append(node)
	return true


func clear_connections():
	for connection in connections:
		var index : int = connection.connections.find(self)
		if index != -1: connection.connections.remove_at(index)
