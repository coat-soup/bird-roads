class_name HullPartSlot
extends Marker3D

@export var symmetrical : bool = false
@export var allow_tall_both_ways : bool = false

@export_range(0.0, 1.0) var resolve_chance : float = 1.0

@export_flags("Small", "Medium", "Large", "Extra Large", "Main Slot") var size : int = 0b00110

@export_flags("Structures", "Sails", "Fins", "Engines", "Tails", "Longsails", "Gasbag", "Other") var allowed_types : int = 0b10001111 # (tails, longsails, & gasbags disabled by default)

var part_data : HullPartData

func resolve() -> void:
	if randf() > resolve_chance: return
	
	var possibilities : Array[HullPartData]
	for p in Resources.hull_parts:
		if ((1 << p.type) & allowed_types) != 0 and ((1 << p.size) & size) != 0 and (allow_tall_both_ways or !p.tall_both_ways):
			possibilities.append(p)
	
	var choice_id = randi() % len(possibilities)
	part_data = possibilities[choice_id]
	var part : Node3D = part_data.prefab.instantiate()
	add_child(part)
	#part.rotation.y = PI
	
	if symmetrical:
		var part2 : Node3D = part_data.prefab.instantiate()
		get_parent().add_child(part2)
		part2.position = Vector3(-position.x, position.y, position.z)
		part2.rotation = rotation
		part2.scale.x = -1
		part2.rotation.z = -rotation.z
		part2.rotation.y = -rotation.y
		part2.reparent(self)
	
	#print(name, " possibilities: ", possibilities, "[", choice_id, "] -> ", part_data.name)
