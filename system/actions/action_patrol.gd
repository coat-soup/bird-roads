class_name ActionPatrol
extends AIAction


func get_weight(character : Character) -> float:
	return 0.5


func perform_action(character : Character):
	action_started.emit()
	on_finished_path(character)
	character.nav_agent.finished_path.connect(on_finished_path.bind(character))


func end_action(character : Character):
	super.end_action(character)
	character.nav_agent.finished_path.disconnect(on_finished_path)


func on_finished_path(character : Character):
	await character.get_tree().create_timer(1.0).timeout
	while len(character.nav_agent.path) == 0:
		character.nav_agent.random_path()
