class_name ActionManCrewStation
extends AIAction

var chosen_station : CrewStation


func get_weight(character : Character) -> float:
	if not character.nav_agent.graph or not character.cur_airship: return 0.0
	
	var valid_station : bool = character.action_manager.is_performing_action_by_name(action_name)
	
	if not valid_station: for station in character.cur_airship.crew_stations:
		if not station.claimed_character:
			valid_station = true
			break
	
	if valid_station: return character.behaviour_manager.boredom - 7
	else: return 0.0



func perform_action(character : Character):
	var shuffled_stations = character.cur_airship.crew_stations
	shuffled_stations.shuffle()
	
	for station in shuffled_stations:
		if not station.claimed_character:
			chosen_station = station
			break
	
	if not chosen_station:
		end_action(character)
		return
	
	var node = character.nav_agent.get_node_closest_to_position(chosen_station.global_position)
	character.nav_agent.set_path_to_node(node)
	character.nav_agent.finished_path.connect(on_finished_path.bind(character))
	
	#DebugDraw3D.draw_sphere(node.global_position, 0.5, Color.WHITE, 15)
	#DebugDraw3D.draw_text(node.global_position + Vector3.UP, character.character_data.character_name + "'s claimed station", 32, Color.WHITE, 15)
	
	chosen_station.claimed_character = character


func end_action(character : Character):
	super.end_action(character)
	character.nav_agent.finished_path.disconnect(on_finished_path)
	if chosen_station and chosen_station.active_character == character:
		chosen_station.end_crewing(character)
	if chosen_station and chosen_station.claimed_character == character: chosen_station.claimed_character = null


func on_finished_path(character : Character):
	print(character.character_data.character_name, " started manning station ", chosen_station)
	chosen_station.start_crewing(character)
	
	#end_action(character)
