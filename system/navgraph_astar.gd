extends RefCounted
class_name NavGraphAStar


static func get_path_between_points(start : NavigationNode, end : NavigationNode, max_closed_length : int = 1000) -> Array[NavigationNode]:
	var open_list : Array[AStarNode] = []
	var closed_list : Array[AStarNode] = []
	
	open_list.append(AStarNode.new(null, start))
	
	while not open_list.is_empty() and len(closed_list) < max_closed_length:
		#get lowest f node
		var cur_node = open_list[0]
		for node in open_list:
			if node.f < cur_node.f: cur_node = node
		
		open_list.remove_at(open_list.find(cur_node))
		closed_list.append(cur_node)
		
		# check completed
		if cur_node.nav_node == end:
			var path : Array[NavigationNode] = []
			var p : AStarNode = cur_node
			while p:
				path.append(p.nav_node)
				p = p.parent
			path.reverse()
			return path
		
		var children : Array[AStarNode]
		for connection in cur_node.nav_node.connections:
			children.append(AStarNode.new(cur_node, connection))
		
		for child in children:
			for c in closed_list: if c.nav_node == child.nav_node: continue # skip closed list
			
			child.g = cur_node.g + 1 # path_length
			child.h = get_heuristic(child, end) # cost
			child.f = child.g + child.h # total cost
			
			for c in closed_list: if c.nav_node == child.nav_node: continue # skip add if already in open list
			open_list.append(child)
	
	print("failed astar. closed_list size: ", len(closed_list))
	return []



static func get_heuristic(node : AStarNode, goal : NavigationNode) -> float:
	var h = abs(goal.position.x - node.nav_node.position.x) + abs(goal.position.y - node.nav_node.position.y) + abs(goal.position.z - node.nav_node.position.z)
	h += abs(node.nav_node.global_position.y - node.parent.nav_node.global_position.y)
	return h
