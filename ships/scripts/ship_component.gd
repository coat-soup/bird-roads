class_name ShipComponent
extends Node3D

signal completed_setup

const DAMAGED_COMPONENT_PARTICLES = preload("uid://bje6xmkj4q347")

var data : HullPartData
@export var health : Health

var airship : Airship

var broken : bool = false
var spawned_particles : Node3D = null

var meshes : Array[MeshInstance3D]


func setup(d : HullPartData, ship : Airship):
	data = d
	airship = ship
	if data.type == HullPartData.HullPartType.ENGINE:
		airship.engines.append(self)
		health.died.connect(airship.calculate_thrust_ratio)
		health.healed.connect(airship.calculate_thrust_ratio)
		health.died.connect(airship.calculate_turn_ratio)
		health.healed.connect(airship.calculate_turn_ratio)
	if data.type == HullPartData.HullPartType.SAIL or data.type == HullPartData.HullPartType.FIN or data.type == HullPartData.HullPartType.TAIL:
		airship.control_surfaces.append(self)
		health.died.connect(airship.calculate_turn_ratio)
		health.healed.connect(airship.calculate_turn_ratio)
	
	if data.durability > 0:
		health.max_health = data.durability
		health.cur_health = data.durability
		health.died.connect(on_health_died)
		
		health.healed.connect(update_mesh_damage)
		health.damaged.connect(update_mesh_damage)
	
	recursive_get_meshes(self)
	
	completed_setup.emit()


func recursive_get_meshes(node : Node):
	var mesh = node as MeshInstance3D
	if mesh: meshes.append(mesh)
	for child in node.get_children(): recursive_get_meshes(child)


func update_mesh_damage():
	for mesh in meshes: mesh.set_instance_shader_parameter("damage_ratio", 1.0 - health.cur_health/health.max_health)


func on_health_died():
	if broken: return
	
	broken = true
	
	spawned_particles = DAMAGED_COMPONENT_PARTICLES.instantiate()
	add_child(spawned_particles)
	if get_node(String(health.name)) as StaticBody3D: spawned_particles.position = health.position
