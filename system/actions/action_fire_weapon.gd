class_name ActionFireWeapon
extends AIAction


func get_weight(character : Character) -> float:
	if character.weapon_manager.cur_weapon.reloading: return 0.0
	var w = 0.0
	for s in character.perception_manager.stimuli:
		if s.stimulus_type == AIPerceptionStimulus.StimulusType.TRACKED_ENEMY and s.time_since_live == 0: w += 1
	return w


func run_action(character : Character):
	character.weapon_manager.try_fire_weapon()
