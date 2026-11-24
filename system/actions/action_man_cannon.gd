class_name ActionManCannon
extends AIAction

var chosen_weapon_platform : WeaponPlatform


func get_weight(character : Character) -> float:
	if not character.nav_agent.graph or not character.cur_airship: return 0.0
	
	return 50


func perform_action(character : Character):
	chosen_weapon_platform = character.cur_airship.weapon_platforms.pick_random()
	var node = character.nav_agent.get_node_closest_to_position(chosen_weapon_platform.global_position)
	character.nav_agent.set_path_to_node(node)
	character.nav_agent.finished_path.connect(on_finished_path.bind(character))



func end_action(character : Character):
	super.end_action(character)
	character.nav_agent.finished_path.disconnect(on_finished_path)
	chosen_weapon_platform.cannon.ai_controller.active = true


func on_finished_path(character : Character):
	chosen_weapon_platform.cannon.ai_controller.active = true
	
	#end_action(character)
