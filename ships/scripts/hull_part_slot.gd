class_name HullPartSlot
extends Marker3D

@export var symmetrical : bool = false
@export var allow_tall_both_ways : bool = false

@export_range(0.0, 1.0) var resolve_chance : float = 1.0

@export_flags("Small", "Medium", "Large", "Extra Large", "Main Slot") var size : int = 0b00110

@export_flags("Structures", "Sails", "Fins", "Engines", "Tails", "Longsails", "Gasbag", "Other") var allowed_types : int = 0b10001111 # (tails, longsails, & gasbags disabled by default)

var part_data : HullPartData
var resolved : bool = false

var override_rand : RandomNumberGenerator = null
var part : Node3D

func resolve(rand : RandomNumberGenerator, generator : ShipExteriorGenerator) -> void:
	if rand.randf() > resolve_chance:
		resolved = true
		symmetrical = false
		return
	if resolved: return
	
	
	var possibilities : Array[HullPartData]
	for p in Resources.hull_parts:
		if ((1 << p.type) & allowed_types) != 0 and ((1 << p.size) & size) != 0 and (allow_tall_both_ways or !p.tall_both_ways):
			possibilities.append(p)
	
	var choice_id = rand.randi() % len(possibilities)
	part_data = possibilities[choice_id]
	part = part_data.prefab.instantiate()
	add_child(part)
	#part.rotation.y = PI
	
	resolved = true
	
	#print(name, " possibilities: ", possibilities, "[", choice_id, "] -> ", part_data.name)


func symmetrise():
	#await get_tree().create_timer(0.5).timeout
	
	var slot2 = part.duplicate()
	get_parent().add_child(slot2)
	slot2.position = Vector3(-position.x, position.y, position.z)
	slot2.rotation = rotation
	slot2.scale.x = -1
	slot2.rotation.z = -rotation.z
	slot2.rotation.y = -rotation.y
	#slot2.symmetrical = false
	#slot2.resolved = true
	slot2.reparent(self)
	
	recursive_flip_normals(slot2)

func recursive_flip_normals(node : Node):
	for child in node.get_children():
		var mesh = child as MeshInstance3D
		if mesh and mesh.global_basis.determinant() < 0: mesh.set_instance_shader_parameter("flip_normals", 1)
		recursive_flip_normals(child)
