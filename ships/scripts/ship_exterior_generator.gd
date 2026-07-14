class_name ShipExteriorGenerator
extends Node

var rigging_points : Array[RiggingPoint]

const SHIP_HULL_MAT = preload("uid://d4fyqk6747sea")

var airship : Airship

@export var hull_mesh : Node3D
@export var color_palette : ShipColorPalette

var seed : int
var rand : RandomNumberGenerator

var queued_component_slots : Array[HullPartSlot]

@export_range(0,1) var structure_weight = 0.7

var speed_req = 10
var maneouvrability_req = 30
var power_req = 2
var cargo_req = 5


func _ready() -> void:
	seed = randi()
	rand = RandomNumberGenerator.new()
	rand.seed = seed
	
	var mat : ShaderMaterial = SHIP_HULL_MAT.duplicate()
	color_palette.resolve_palette(rand)
	
	var parent : Node = self
	while not airship and airship != get_tree().root:
		parent = parent.get_parent()
		airship = parent as Airship
	
	
	print("generating exterior of ship with speed: ", airship.actor_data.speed, ",  cargo: ", airship.actor_data.cargo_capacity, ", power: ", airship.actor_data.combat_power)
	
	speed_req = airship.actor_data.speed
	power_req = airship.actor_data.combat_power
	cargo_req = airship.actor_data.cargo_capacity
	
	recursive_resolve_slots(self, mat, HullPartData.HullPartType.STRUCTURE, false)
	recursive_resolve_slots(hull_mesh, mat, HullPartData.HullPartType.STRUCTURE, false)
	
	
	await get_tree().create_timer(0.5).timeout
	
	var n_points = rigging_points.size()
	for i in range(n_points-1,-1,-1):
		if !is_instance_valid(rigging_points[i]): rigging_points.remove_at(i)
	for p in rigging_points: p.rig(rigging_points)


func recursive_resolve_slots(node : Node, material : ShaderMaterial, part_type : HullPartData.HullPartType, do_non_structure : bool):
	var rope : RiggingPoint = node as RiggingPoint
	if rope: rigging_points.append(rope)
	
	var random_child : RandomChild = node as RandomChild
	if random_child: random_child.resolve(rand)
	
	var hardpoint_slot : HardpointSlot = node as HardpointSlot
	if hardpoint_slot:
		if hardpoint_slot.resolved: return
		hardpoint_slot.resolve(rand, self)
	
	var hull_slot : HullPartSlot = node as HullPartSlot
	if hull_slot:
		if hull_slot.resolved: return
		var structurised = false
		# do structure_weight check if can host structure or gasbag
		if (((1 << 0) & hull_slot.allowed_types) != 0 or ((1 << 6) & hull_slot.allowed_types) != 0) and randf() < structure_weight:
			hull_slot.allowed_types &= 0b01000001
			structurised = true
		# force other types if failed check
		elif hull_slot.allowed_types & 0b10111110: hull_slot.allowed_types &= 0b10111110
		
		# set structurised if ONLY gasbag or structure
		if not hull_slot.allowed_types & 0b10111110: structurised = true
		
		var selected_type : int = -1
		
		if not structurised:
			selected_type = rand.rand_weighted([speed_req, # engines
													maneouvrability_req, # control surfaces
													10]) # don't force
			if selected_type == 0: hull_slot.allowed_types &= 0b00001000
			elif selected_type == 1: hull_slot.allowed_types &= 0b00010110
		
		hull_slot.resolve(rand, self)
		if hull_slot.part_data:
			if hull_slot.part_data.type == HullPartData.HullPartType.ENGINE: speed_req -= hull_slot.part_data.power
			elif (hull_slot.part_data.type == HullPartData.HullPartType.TAIL
				or hull_slot.part_data.type == HullPartData.HullPartType.FIN
				or hull_slot.part_data.type == HullPartData.HullPartType.SAIL): maneouvrability_req -= hull_slot.part_data.power
		#if (structurised and !do_non_structure) or do_non_structure:
		#	hull_slot.resolve(rand, self)
		#	if hull_slot.part_data: part_type = hull_slot.part_data.type
		#else:
		#	queued_component_slots.append(hull_slot)
	
	var mesh = node as MeshInstance3D
	if mesh:
		mesh.material_overlay = material
		color_palette.colourise_part(mesh, part_type)
		
	for child in node.get_children(): recursive_resolve_slots(child, material, part_type, do_non_structure)
	
	if hull_slot and hull_slot.symmetrical:
		hull_slot.symmetrise()


func order_hull_slots(a : HullPartSlot, b : HullPartSlot) -> bool:
	return Util.bit_count(a.allowed_types) > Util.bit_count(b.allowed_types)
