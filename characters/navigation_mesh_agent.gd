class_name NavigationMeshAgent
extends Node

signal finished_path

const TICK_RATE : float = 5
@export var graph : NavigationGraph
@export var character : Character

@export var string_pull_dist : int = 3


var path : Array[NavigationNode]
var cur_node : NavigationNode


func _ready() -> void:
	tick()


func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_5): random_path()


func random_path():
	var end = null
	while not end: end = graph.nodes.pick_random()
	
	path = NavGraphAStar.get_path_between_points(cur_node, end)


func set_path_to_position(pos : Vector3):
	var end = get_node_closest_to_position(pos)
	path = NavGraphAStar.get_path_between_points(cur_node, end)


func set_path_to_node(node : NavigationNode):
	path = NavGraphAStar.get_path_between_points(cur_node, node)


func clear_path():
	path = []


func _process(delta: float) -> void:
	if len(path) < 1: return
	DebugDraw3D.scoped_config().set_thickness(0.2)
	DebugDraw3D.draw_sphere(path[0].global_position)
	DebugDraw3D.draw_sphere(path[-1].global_position)
	
	for i in range(len(path) - 1):
		DebugDraw3D.draw_line(path[i].global_position, path[i+1].global_position, Color.BLUE)


func get_next_node_in_path() -> NavigationNode:
	if len(path) == 0: return null
	for i in range(len(path)):
		if character.global_position.distance_to(path[i].global_position) < graph.spacing * 0.5:
			if i < len(path): path = path.slice(i+1)
			if len(path) == 0:
				finished_path.emit()
				return null
			break
	var pull_ahead : int = 0
	var space_state = character.get_world_3d().direct_space_state
	for i in range(min(string_pull_dist, len(path)-1), -1, -1):
		var query = PhysicsShapeQueryParameters3D.new()
		query.collision_mask = Util.layer_mask([1, 16])
		query.shape = SphereShape3D.new()
		query.shape.radius = 0.4
		query.transform.origin = character.global_position + Vector3.UP * 0.5
		query.motion = path[i].global_position - character.global_position
		var result = space_state.cast_motion(query)
		if result[0] == 1.0:
			pull_ahead = i
			break
	
	return path[pull_ahead]


func tick():
	if graph:
		cur_node = get_node_closest_to_position(character.global_position)
	
	await get_tree().create_timer(1.0/TICK_RATE).timeout
	tick()


func get_closest_cover_node(danger_position : Vector3, min_distance_to_danger : float = 10.0) -> NavigationNode:
	var visited : Array[NavigationNode] = []
	var breadth_first_queue : Array[NavigationNode] = [cur_node]
	while breadth_first_queue.size() > 0:
		var node : NavigationNode = breadth_first_queue.pop_front()
		if not node.cover_directions.is_empty() and node.global_position.distance_to(danger_position) >= min_distance_to_danger: for dir in node.cover_directions:
			if dir.dot((danger_position - character.global_position).normalized()) > 0.5:
				return node
		
		visited.append(node)
		for c in node.connections:
			if not visited.has(c): breadth_first_queue.append(c)
		
	return null


func get_node_closest_to_position(pos : Vector3) -> NavigationNode:
	var closest : NavigationNode = null
	var c_dist : float = 0
	for node in graph.nodes:
		if not node: continue
		var dist = pos.distance_to(node.global_position)
		if closest == null or dist < c_dist:
			closest = node
			c_dist = dist
	return closest
