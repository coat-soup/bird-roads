class_name AIPerceptionManager
extends Area3D

@onready var character: Character = $".."

signal perception_updated

var stimuli : Array[AIPerceptionStimulus]

var tick_speed = 2.0

@export var dead_stim_remove_time : float = 5.0

func _ready() -> void: tick()


func tick():
	# get new stimuli loop
	var bodies = get_overlapping_bodies()
	for body in bodies:
		var target : CharacterBody3D = body as Character
		if !target: target = body as Player
		if not target or target == character or not can_see_target(target): continue
		var stim : AIPerceptionStimulus = null
		for s in stimuli: if s.source_node == target:
			stim = s
			break
		if not stim:
			var type = AIPerceptionStimulus.StimulusType.TRACKED_ALLY if is_target_friendly(target) else AIPerceptionStimulus.StimulusType.TRACKED_ENEMY
			stim = AIPerceptionStimulus.new(type, target, Vector3.ZERO)
			stimuli.append(stim)
			target.health.died.connect(on_stimulus_character_died.bind(target))
			perception_updated.emit()
	
	for i in range(len(stimuli)-1, -1, -1):
		if (stimuli[i].source_node and not can_see_target(stimuli[i].source_node)
			or stimuli[i].stimulus_type == AIPerceptionStimulus.StimulusType.VISUAL_ATTENTION):
			stimuli[i].time_since_live += 1.0/tick_speed
			if stimuli[i].time_since_live >= dead_stim_remove_time:
				var char = stimuli[i].source_node as Character
				if char: char.health.died.disconnect(on_stimulus_character_died)
				stimuli.remove_at(i)
				perception_updated.emit()
		else:
			stimuli[i].time_since_live = 0
	
	await get_tree().create_timer(1.0/tick_speed).timeout
	tick()


func on_stimulus_character_died(char : Character):
	for i in range(len(stimuli)):
		if stimuli[i].source_node == char:
			stimuli.remove_at(i)
			break
	char.health.died.disconnect(on_stimulus_character_died)
	perception_updated.emit()


func can_see_target(target : Node3D) -> bool:
	return true
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(target.global_position + Vector3.UP * 0.5, target.global_position + Vector3.UP * 0.5, Util.layer_mask([1,2]), [character]))
	return result and result.collider == target


func get_main_target() -> Node3D:
	if stimuli.is_empty(): return null
	var stims = stimuli
	stims.sort_custom(func(a : AIPerceptionStimulus, b : AIPerceptionStimulus):
		if a.stimulus_type == AIPerceptionStimulus.StimulusType.TRACKED_ENEMY and b.stimulus_type != AIPerceptionStimulus.StimulusType.TRACKED_ENEMY: return true
		elif a.stimulus_type != AIPerceptionStimulus.StimulusType.TRACKED_ENEMY and b.stimulus_type == AIPerceptionStimulus.StimulusType.TRACKED_ENEMY: return false
		else: return a.time_since_live < b.time_since_live
		)
		
	return stims[0].source_node if stims[0].stimulus_type == AIPerceptionStimulus.StimulusType.TRACKED_ENEMY else null


func is_target_friendly(target : Node) -> bool:
	if target as Player: return character.squad_id == 1
	else: return (target as Character).squad_id == character.squad_id


func _process(delta: float) -> void:
	var t = ""
	for stim in stimuli: t += stim.source_node.name + ": " + str(stim.time_since_live) + "s,"
	$"../DebugUI/StimuliDebugLabel".text = "[" + t.left(t.length() - 1) + "]"
