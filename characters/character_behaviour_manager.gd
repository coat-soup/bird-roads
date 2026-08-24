class_name CharacterBehaviourManager
extends Node

@onready var action_manager: ActionManager = $"../ActionManager"
@onready var action_debug_label: Label3D = $"../ActionDebugLabel"

@export var patience : float = 1.0
var boredom : float = 3.0


func _process(delta: float) -> void:
	boredom += delta / patience
	
	action_debug_label.look_at(get_viewport().get_camera_3d().global_position, Vector3.UP, true)
	var actions = action_manager.current_actions
	var t = ""
	for a in actions: t += a.action_name + ","
	action_debug_label.text = "[" + t.left(t.length() - 1) + "]"
	action_debug_label.text += "\n bdm: %.0f" % boredom
