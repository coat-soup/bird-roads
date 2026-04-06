class_name HardpointData
extends Resource

@export var name : String
@export var prefab : PackedScene

enum HardpointType {CARGO, WEAPON, EQUIPMENT}
@export var type : HardpointType

@export_enum("Small", "Medium", "Large", "Extra Large") var size : int


func _to_string() -> String:
	return name
