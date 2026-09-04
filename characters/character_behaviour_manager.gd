class_name CharacterBehaviourManager
extends Node

@onready var character: Character = $".."


@onready var action_manager: ActionManager = $"../ActionManager"
@onready var action_debug_label: Label3D = $"../DebugUI/ActionDebugLabel"
@onready var progress_bar: ProgressBar = $"../DebugUI/Sprite3D/SubViewport/Control/ProgressBar"
@onready var name_label: Label3D = $"../DebugUI/NameLabel"



var boredom : float = 3.0


func _ready() -> void:
	await get_tree().process_frame
	name_label.text = character.character_data.character_name


func _process(delta: float) -> void:
	boredom += delta / 1.0 + StatModifiers.patience_boredome * character.character_data.traits["patience"]
	
	$"../DebugUI".look_at(get_viewport().get_camera_3d().global_position, Vector3.UP, true)
	var actions = action_manager.current_actions
	var t = ""
	for a in actions: t += a.action_name + ","
	action_debug_label.text = "[" + t.left(t.length() - 1) + "]"
	action_debug_label.text += "\n bdm: %.0f" % boredom
	progress_bar.value = character.health.cur_health/character.health.max_health
