class_name ActionTakeCover
extends AIAction


func get_weight(character : Character) -> float:
	var w = 0.0
	for s in character.perception_manager.stimuli:
		if s.stimulus_type == AIPerceptionStimulus.StimulusType.TRACKED_ENEMY: w += 1
	return w


func run_action(character : Character):
	var danger : Vector3
	for s in character.perception_manager.stimuli:
		if s.stimulus_type == AIPerceptionStimulus.StimulusType.TRACKED_ENEMY:
			danger = s.source_node.global_position
			break
	character.nav_agent.set_path_to_node(character.nav_agent.get_closest_cover_node(danger))
