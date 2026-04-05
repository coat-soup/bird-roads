class_name ShipExteriorGenerator
extends Node

var rigging_points : Array[RiggingPoint]

const SHIP_HULL_MAT = preload("uid://d4fyqk6747sea")


@export var hull_mesh : Node3D
@export var color_palette : ShipColorPalette


func _ready() -> void:
	recursive_resolve_slots(self)
	
	await get_tree().create_timer(0.5).timeout
	
	var n_points = rigging_points.size()
	for i in range(n_points-1,-1,-1):
		if !is_instance_valid(rigging_points[i]): rigging_points.remove_at(i)
	for p in rigging_points: p.rig(rigging_points)
	
	var mat : ShaderMaterial = SHIP_HULL_MAT.duplicate()
	color_palette.resolve_palette()
	recursive_set_child_materials(self, mat, HullPartData.HullPartType.STRUCTURE)
	
	recursive_set_child_materials(hull_mesh, mat, HullPartData.HullPartType.STRUCTURE)


func recursive_resolve_slots(node : Node):
	for child in node.get_children():
		var random_child : RandomChild = child as RandomChild
		if random_child: random_child.resolve()
		var hull_slot : HullPartSlot = child as HullPartSlot
		if hull_slot: hull_slot.resolve()
		var rope : RiggingPoint = child as RiggingPoint
		if rope: rigging_points.append(rope)
		
		recursive_resolve_slots(child)


func recursive_set_child_materials(node : Node, material : ShaderMaterial, part_type : HullPartData.HullPartType):
	for child in node.get_children():
		var hull_slot : HullPartSlot = child as HullPartSlot
		if hull_slot and hull_slot.part_data:
			part_type = hull_slot.part_data.type
		
		var mesh = child as MeshInstance3D
		if mesh:
			mesh.material_overlay = material
			color_palette.colourise_part(mesh, part_type)
		
		var rope = child as CSGBox3D
		if rope:
			rope.material_overlay = material
			rope.set_instance_shader_parameter("quintary_color", Color(79, 79, 79) / 255)
		
		recursive_set_child_materials(child, material, part_type)
