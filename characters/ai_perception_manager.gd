class_name AIPerceptionManager
extends Area3D

@onready var character: Character = $".."

signal perception_updated

var stimuli : Array[AIPerceptionStimulus]

var tick_speed = 2.0

@export var dead_stim_remove_time : float = 5.0

func _ready() -> void: tick()


func tick():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		var char : Character = body as Character
		if not char or char == character: continue
		var stim : AIPerceptionStimulus = null
		for s in stimuli: if s.source_node == char:
			stim = s
			break
		if not stim:
			# TODO: use actual friend-foe system
			var type = AIPerceptionStimulus.StimulusType.TRACKED_ENEMY
			stim = AIPerceptionStimulus.new(type, char, Vector3.ZERO)
			stimuli.append(stim)
			perception_updated.emit()
	
	for i in range(len(stimuli)-1, -1, -1):
		if (stimuli[i].source_node and not can_see_target(stimuli[i].source_node)
			or stimuli[i].stimulus_type == AIPerceptionStimulus.StimulusType.VISUAL_ATTENTION):
			stimuli[i].time_since_live += 1.0/tick_speed
			if stimuli[i].time_since_live >= dead_stim_remove_time:
				stimuli.remove_at(i)
				perception_updated.emit()
		else:
			stimuli[i].time_since_live = 0
	
	await get_tree().create_timer(1.0/tick_speed).timeout
	tick()


func can_see_target(char : Character) -> bool:
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(character.global_position + Vector3.UP * 0.5, char.global_position + Vector3.UP * 0.5, Util.layer_mask([1,2]), [character]))
	return result and result.collider == char
