class_name ShipComponent
extends Node3D

signal completed_setup

const DAMAGED_COMPONENT_PARTICLES = preload("uid://bje6xmkj4q347")

var data : HullPartData
@export var health : Health
@export var center_point : Node3D

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
	if mesh:
		meshes.append(mesh)
		mesh.mesh = mesh.mesh.duplicate()
	for child in node.get_children(): recursive_get_meshes(child)


func update_mesh_damage():
	for mesh in meshes:
		mesh.set_instance_shader_parameter("damage_ratio", 1.0 - health.cur_health/health.max_health)


func on_health_died():
	if broken: return
	
	broken = true
	
	spawned_particles = DAMAGED_COMPONENT_PARTICLES.instantiate()
	add_child(spawned_particles)
	if get_node(String(health.name)) as StaticBody3D: spawned_particles.position = health.position


func paint_mesh_damage(pos : Vector3, damage : float, radius : float):
	for mesh in meshes:
		var local_pos : Vector3 = mesh.to_local(pos)
		var aabb : AABB = mesh.get_aabb().grow(radius * 1)
		if !aabb.has_point(local_pos): continue
		
		var meshdata = MeshDataTool.new()
		meshdata.create_from_surface(mesh.mesh, 0)
		
		
		for i in range(meshdata.get_vertex_count()):
			var vertex := meshdata.get_vertex(i)
			var vertex_distance:float = vertex.distance_to(local_pos)
		
			if vertex_distance < radius:
				var linear_distance = 1 - (vertex_distance / radius)
				var calculated_hardness = linear_distance * damage/50.0
				var cur_color : Color = meshdata.get_vertex_color(i)
				var new_color : Color = cur_color + Color(0,0,1) * calculated_hardness * (0.5 if cur_color.g > 0.6 else 1.0)
				meshdata.set_vertex_color(i, new_color)
		
		mesh.mesh.surface_remove(0)
		meshdata.commit_to_surface(mesh.mesh)



func paint_mesh_damage_threaded(pos : Vector3, damage : float, radius : float):
	for mesh in meshes:
		var meshdata : MeshDataTool = MeshDataTool.new()
		meshdata.create_from_surface(mesh.mesh, 0)
		
		var task = WorkerThreadPool.add_group_task(process_paint_mesh_damage_threaded.bind(mesh.to_local(pos), damage, radius, mesh, meshdata), meshdata.get_vertex_count())
		WorkerThreadPool.wait_for_group_task_completion(task)
		mesh.mesh.surface_remove(0)
		meshdata.commit_to_surface(mesh.mesh)


func process_paint_mesh_damage_threaded(i: int, pos : Vector3, damage : float, radius : float, mesh : MeshInstance3D, meshdata : MeshDataTool):
		var vertex := meshdata.get_vertex(i)
		var vertex_distance:float = vertex.distance_to(pos)
		if vertex_distance < radius:
			var linear_distance = 1 - (vertex_distance / radius)
			var calculated_hardness = linear_distance * damage/50.0
			var cur_color : Color = meshdata.get_vertex_color(i)
			var new_color : Color = cur_color + Color(0,0,1) * calculated_hardness * (0.0 if cur_color.g > 0.6 else 1.0)
			meshdata.set_vertex_color(i, new_color)
