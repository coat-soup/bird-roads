class_name ActionDebugFollowCam
extends AIAction


func get_weight(character : Character) -> float:
	if not character.get_viewport().get_camera_3d(): return 0
	var d : float = character.get_viewport().get_camera_3d().global_position.distance_to(character.global_position)
	if d > 10: return 0
	else: return 1.0 - d/10.0


func run_action(character : Character):
	character.nav_agent.clear_path()
	character.velocity = (character.get_viewport().get_camera_3d().global_position - character.global_position).normalized() * character.speed
	character.velocity.y = 0
