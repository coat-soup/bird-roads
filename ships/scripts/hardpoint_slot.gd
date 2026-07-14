class_name HardpointSlot
extends Marker3D

@export_flags("Small", "Medium", "Large", "Extra Large") var size : int = 0b0010
@export_flags("Cargo", "Weapon", "Equipment") var allowed_types : int = 0b111

@export_range(0,1) var move_weapon_forward : float = 0

@export var symmetry_connection : HardpointSlot = null

static var weapon_size_to_power : Array[int] = [1,2,3,5]

var resolved : bool = false
var hardpoint : Node3D
var hardpoint_data : HardpointData
var weapon_data : ShipWeaponData

func resolve(rand : RandomNumberGenerator, generator : ShipExteriorGenerator):
	var selected_type = rand.rand_weighted([generator.power_req * (0 if allowed_types & 0b010 == 0 else 1), # weapons
											generator.cargo_req * (0 if allowed_types & 0b001 == 0 else 1), # cargo
											1]) # don't force
	if selected_type == 0: allowed_types = 0b010
	elif selected_type == 1: allowed_types = 0b001
	
	var possibilities : Array[HardpointData]
	if !(symmetry_connection and symmetry_connection.resolved):
		for p in Resources.hardpoints:
			var invalidates_power : bool = false
			
			if (p.type == HardpointData.HardpointType.WEAPON and
			weapon_size_to_power[p.size] * (2 if symmetry_connection else 1) > generator.power_req):
				print("cant place weapon, ", weapon_size_to_power[p.size] * (2 if symmetry_connection else 1), " > ", generator.power_req)
				invalidates_power = true
			
			if (p.type == HardpointData.HardpointType.CARGO and
			(2 if symmetry_connection else 1) > generator.cargo_req): invalidates_power = true
			
			if not invalidates_power and ((1 << p.type) & allowed_types) != 0 and ((1 << p.size) & size) != 0:
				possibilities.append(p)
		
		if len(possibilities) > 0:
			var choice_id = rand.randi() % len(possibilities)
			hardpoint_data = possibilities[choice_id]
	else:
		hardpoint_data = symmetry_connection.hardpoint_data
	
	if not hardpoint_data:
		resolved = true
		return
	
	hardpoint = hardpoint_data.prefab.instantiate()
	add_child(hardpoint)
	
	if hardpoint_data.type == HardpointData.HardpointType.WEAPON:
		generator.power_req -= weapon_size_to_power[hardpoint_data.size]
		
		hardpoint.position.z = 2.8 * move_weapon_forward;
		var weapon_possibilities : Array[ShipWeaponData]
		if !(symmetry_connection and symmetry_connection.resolved):
			for p in Resources.ship_weapons:
				if p.size == hardpoint_data.size:
					weapon_possibilities.append(p)
			
			var choice_id = rand.randi() % len(weapon_possibilities)
			weapon_data = weapon_possibilities[choice_id]
		else:
			weapon_data = symmetry_connection.weapon_data
		
		var weapon = weapon_data.prefab.instantiate()
		hardpoint.get_child(0).add_child(weapon)
		
	elif hardpoint_data.type == HardpointData.HardpointType.CARGO:
		generator.cargo_req -= hardpoint_data.size
	
	resolved = true
