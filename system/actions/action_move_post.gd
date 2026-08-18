class_name ActionMovePost
extends AIAction


func get_weight(character : Character) -> float:
	var target = character.perception_manager.get_main_target()
	if not target: return 0.0
	return -10 + get_post_cost(character, character.nav_agent.cur_node, target, character.get_world_3d().direct_space_state)


func perform_action(character : Character):
	var costs = get_post_costs(character)
	if not costs.is_empty():
		var lowest_i = 0
		for i in range(len(costs)):
			if costs[i] < costs[lowest_i]: lowest_i = i
		character.nav_agent.set_path_to_node(character.nav_agent.graph.nodes[character.nav_agent.graph.cover_nodes[lowest_i]])
		character.behaviour_manager.boredom = 0
		
		character.nav_agent.finished_path.connect(on_finished_path.bind(character))
	else: end_action(character)


func end_action(character : Character):
	super.end_action(character)
	character.nav_agent.finished_path.disconnect(on_finished_path)


func on_finished_path(character : Character):
	end_action(character)


func get_post_costs(character : Character) -> Array[float]:
	var costs : Array[float] = []
	
	var target = character.perception_manager.get_main_target()
	if not target: return []
	
	var space_state = character.get_world_3d().direct_space_state
	
	for cover_i in character.nav_agent.graph.cover_nodes:
		costs.append(get_post_cost(character, character.nav_agent.graph.nodes[cover_i], target, space_state))
	return costs


func get_post_cost(character : Character, post_node : NavigationNode, target : Node3D, space_state : PhysicsDirectSpaceState3D) -> float:
	if not post_node: return 10000000000000
	var c_distance_to_target = post_node.global_position.distance_to(target.global_position) / 30.0
	var c_distance_from_self = post_node.global_position.distance_to(character.global_position) / 30.0
	
	var c_cover = 20.0 if not space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		post_node.global_position, target.global_position,
		Util.layer_mask([1,2]), [character, target]
	)) else 0.0
	
	var c_los = 20.0 if space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		post_node.global_position + Vector3(0,0.5,0), target.global_position + Vector3(0,.5,0),
		Util.layer_mask([1,2]), [character, target]
	)) else 0.0
	
	var c_stay = character.behaviour_manager.boredom / max(post_node.global_position.distance_to(character.nav_agent.cur_node.global_position), 1.0)
	#if post_node == character.nav_agent.cur_node: c_stay += character.behaviour_manager.boredom
	
	return c_distance_to_target + c_distance_from_self + c_cover + c_los + c_stay
