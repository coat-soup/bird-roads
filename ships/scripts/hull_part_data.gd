class_name HullPartData
extends Resource

@export var name : String
@export var prefab : PackedScene

enum HullPartType {STRUCTURE, SAIL, FIN, ENGINE, TAIL, LONGSAIL, GASBAG, OTHER}

@export var type : HullPartType

@export_enum("Small", "Medium", "Large", "Extra Large", "Main Slot") var size : int

@export var tall_both_ways : bool = false

## only applicable for engines and fins/sails
@export var power : int = 0

func _to_string() -> String:
	return name
