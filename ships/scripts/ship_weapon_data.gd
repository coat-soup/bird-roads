class_name ShipWeaponData
extends Resource

@export var name : String
@export var prefab : PackedScene

enum ShipWeaponType {HEAVY_CANON, LIGHT_CANNON, ROCKET}
@export var type : ShipWeaponType

@export_enum("Small", "Medium", "Large", "Extra Large") var size : int

@export var pilot_controlled : bool = false
