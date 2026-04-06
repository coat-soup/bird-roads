class_name HardpointSlot
extends Marker3D

@export_flags("Small", "Medium", "Large", "Extra Large") var size : int = 0b0010
@export_flags("Cargo", "Weapon", "Equipment") var allowed_types : int = 0b111 # (tails, longsails, & gasbags disabled by default)

@export_range(0,1) var move_weapon_forward : float = 0

@export var symmetry_connection : HardpointSlot = null

var resolved : bool = false
var hardpoint : Node3D
var hardpoint_data : HardpointData
var weapon_data : ShipWeaponData

func resolve(rand : RandomNumberGenerator):
	var possibilities : Array[HardpointData]
	if !(symmetry_connection and symmetry_connection.resolved):
		for p in Resources.hardpoints:
			if ((1 << p.type) & allowed_types) != 0 and ((1 << p.size) & size) != 0:
				possibilities.append(p)
		
		var choice_id = rand.randi() % len(possibilities)
		hardpoint_data = possibilities[choice_id]
	else:
		hardpoint_data = symmetry_connection.hardpoint_data
	
	hardpoint = hardpoint_data.prefab.instantiate()
	add_child(hardpoint)
	
	if hardpoint_data.type == HardpointData.HardpointType.WEAPON:
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
	
	resolved = true
