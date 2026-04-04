class_name ShipExteriorGenerator
extends Node

var rigging_points : Array[RiggingPoint]

const SHIP_HULL_MAT = preload("uid://d4fyqk6747sea")


@export var hull_mesh : MeshInstance3D
@export var color_palette : ShipColorPalette


func _ready() -> void:
	
	await get_tree().create_timer(0.5).timeout
	
	for p in rigging_points:
		p.rig(rigging_points)
	
	var mat : ShaderMaterial = SHIP_HULL_MAT.duplicate()
	color_palette.resolve_palette()
	recursive_set_child_materials(self, mat, HullPartData.HullPartType.STRUCTURE)
	
	hull_mesh.material_overlay = mat
	color_palette.colourise_part(hull_mesh, HullPartData.HullPartType.STRUCTURE)


func recursive_set_child_materials(node : Node, material : ShaderMaterial, part_type : HullPartData.HullPartType):
	for child in node.get_children():
		var hull_slot : HullPartSlot = child as HullPartSlot
		if hull_slot:
			part_type = hull_slot.part_data.type
		
		var mesh = child as MeshInstance3D
		if mesh:
			mesh.material_overlay = material
			color_palette.colourise_part(mesh, part_type)
		recursive_set_child_materials(child, material, part_type)
