class_name ShipExteriorGenerator
extends Node

var rigging_points : Array[RiggingPoint]

const SHIP_HULL_MAT = preload("uid://d4fyqk6747sea")


@export var hull_mesh : Node3D
@export var color_palette : ShipColorPalette

var seed : int
var rand : RandomNumberGenerator


func _ready() -> void:
	seed = randi()
	rand = RandomNumberGenerator.new()
	rand.seed = seed
	
	var mat : ShaderMaterial = SHIP_HULL_MAT.duplicate()
	color_palette.resolve_palette(rand)
	
	recursive_resolve_slots(self, mat, HullPartData.HullPartType.STRUCTURE)
	recursive_resolve_slots(hull_mesh, mat, HullPartData.HullPartType.STRUCTURE)
	
	await get_tree().create_timer(0.5).timeout
	
	var n_points = rigging_points.size()
	for i in range(n_points-1,-1,-1):
		if !is_instance_valid(rigging_points[i]): rigging_points.remove_at(i)
	for p in rigging_points: p.rig(rigging_points)


func recursive_resolve_slots(node : Node, material : ShaderMaterial, part_type : HullPartData.HullPartType):	
	var rope : RiggingPoint = node as RiggingPoint
	if rope: rigging_points.append(rope)
	
	var random_child : RandomChild = node as RandomChild
	if random_child: random_child.resolve(rand)
	
	var hardpoint_slot : HardpointSlot = node as HardpointSlot
	if hardpoint_slot:
		if hardpoint_slot.resolved: return
		hardpoint_slot.resolve(rand)
	
	var hull_slot : HullPartSlot = node as HullPartSlot
	if hull_slot:
		if hull_slot.resolved: return
		hull_slot.resolve(rand, self)
		if hull_slot.part_data: part_type = hull_slot.part_data.type
	
	var mesh = node as MeshInstance3D
	if mesh:
		mesh.material_overlay = material
		color_palette.colourise_part(mesh, part_type)
		
	for child in node.get_children(): recursive_resolve_slots(child, material, part_type)
	
	if hull_slot and hull_slot.symmetrical:
		hull_slot.symmetrise()
