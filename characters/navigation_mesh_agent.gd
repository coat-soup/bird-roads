class_name NavigationMeshAgent
extends Node

signal finished_path

const TICK_RATE : float = 5
@export var graph : NavigationGraph
@export var character : Character

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


func get_path_to_position(pos : Vector3):
	var end = get_node_closest_to_position(pos)
	path = NavGraphAStar.get_path_between_points(cur_node, end)


func _process(delta: float) -> void:
	if len(path) < 1: return
	DebugDraw3D.scoped_config().set_thickness(0.5)
	DebugDraw3D.draw_sphere(path[0].global_position)
	DebugDraw3D.draw_sphere(path[-1].global_position)
	
	for i in range(len(path) - 1):
		DebugDraw3D.draw_line(path[i].global_position, path[i+1].global_position, Color.BLUE)


func get_next_node_in_path() -> NavigationNode:
	if len(path) == 0: return null
	if character.global_position.distance_to(path[0].global_position) < graph.spacing * 0.5:
		path.remove_at(0)
		if len(path) == 0:
			finished_path.emit()
			return null
	return path[0]


func tick():
	cur_node = get_node_closest_to_position(character.global_position)
	
	await get_tree().create_timer(1.0/TICK_RATE).timeout
	tick()


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
