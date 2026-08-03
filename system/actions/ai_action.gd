class_name AIAction
extends Resource

signal action_started
signal action_ended

@export var action_name : StringName
@export var blocking : bool = false
@export var interruptable : bool = true
var target_location : Vector3
var target_node : Node


func get_weight(character : Character) -> float:
	return 0

func can_perform_action(character : Character) -> float: return true

func perform_action(character : Character):
	action_started.emit()

func run_action(character : Character): pass
func end_action(character : Character):
	action_ended.emit()

func _to_string() -> String:
	return action_name
