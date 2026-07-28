extends RefCounted
class_name AStarNode

var parent : AStarNode
var nav_node : NavigationNode

var g : float
var h : float
var f : float

func _init(p : AStarNode, node : NavigationNode) -> void:
	parent = p
	nav_node = node
	g = 0
	h = 0
	f = 0
