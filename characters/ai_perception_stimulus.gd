class_name AIPerceptionStimulus
extends RefCounted

enum StimulusType {AUDIO_ATTENTION, VISUAL_ATTENTION, TRACKED_ALLY, TRACKED_ENEMY, TRACKED_NEUTRAL}

var source_node : Node3D
var source_loction : Vector3

var stimulus_type : StimulusType
var time_since_live : float = 0.0


func _init(type : StimulusType, node : Node, location : Vector3) -> void:
	stimulus_type = type
	source_node = node
	source_loction = location
