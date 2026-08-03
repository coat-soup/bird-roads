extends Node
class_name ActionManager

signal performed_action(AIAction)
signal ended_action(AIAction)

@onready var character: Character = $".."
@export var action_set : Array[AIAction]
var current_actions : Array[AIAction]

var action_weights = {}
var tick_speed = 5.0


func _ready() -> void: tick()


func tick():
	check_action_weights()
	for action in current_actions: action.run_action(character)
	await get_tree().create_timer(1.0/tick_speed).timeout
	tick()


func check_action_weights():
	for action in action_set:
		action_weights[action.action_name] = action.get_weight(character)
	
	var best_blocking_action_id = -1
	var best_blocking_action_weight = -1
	for i in range(len(action_set)):
		if action_set[i].blocking:
			if action_weights[action_set[i].action_name] > best_blocking_action_weight:
				best_blocking_action_id = i
				best_blocking_action_weight = action_weights[action_set[i].action_name]
	
	for i in range(len(action_set)):
		if action_weights[action_set[i].action_name] >= 0.5 and (!action_set[i].blocking or i == best_blocking_action_id):
			try_perform_action_by_name(action_set[i].action_name)
		else:
			try_stop_action_by_name(action_set[i].action_name)


func try_perform_action_by_name(action_name : String) -> bool:
	#TODO: work in stunned state
	#if character.weapon_manager.attack_state == WeaponManager.AttackState.STUNNED: return false
	
	for i in range(len(current_actions)):
		if current_actions[i].action_name == action_name:
			return false
	
	for i in range(len(action_set)):
		if action_set[i].action_name == action_name and action_set[i].can_perform_action(character):
			perform_action(i)
			return true
	
	return false


func try_stop_action_by_name(action_name : String, override_interruptable : bool = false):
	for i in range(len(current_actions)):
		if current_actions[i].action_name == action_name and not current_actions[i].interruptable and not override_interruptable:
			return
	end_action(action_name)


func is_performing_action_by_name(action_name : String) -> bool:
	for action in current_actions:
		if action.action_name == action_name: return true
	return false


func is_performing_blocking_action() -> bool:
	for action in current_actions:
		if action.blocking: return true
	return false


func perform_action(action_id : int):
	var c_action = action_set[action_id].duplicate()
	current_actions.append(c_action)
	c_action.perform_action(character)
	c_action.action_ended.connect(on_action_ended.bind(c_action))
	
	performed_action.emit(c_action)


func end_action(action_name : String):
	var t_action : AIAction
	for action in current_actions:
		if action.action_name == action_name:
			t_action = action
			action.end_action(character)
	
	ended_action.emit(t_action)


func on_action_ended(action : AIAction):
	var id = current_actions.find(action)
	if id != null:
		current_actions[id].action_ended.disconnect(on_action_ended)
		current_actions.remove_at(id)


func get_action_by_name(action_name : String) -> AIAction:
	for action in action_set:
		if action.action_name == action_name: return action
	return null
