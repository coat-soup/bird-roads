class_name CharacterBehaviourManager
extends Node

@onready var action_manager: ActionManager = $"../ActionManager"
@onready var action_debug_label: Label3D = $"../ActionDebugLabel"


func _process(delta: float) -> void:
	action_debug_label.look_at(get_viewport().get_camera_3d().global_position, Vector3.UP, true)
	var actions = action_manager.current_actions
	var t = ""
	for a in actions: t += a.action_name + ","
	action_debug_label.text = "[" + t.left(t.length() - 1) + "]"
