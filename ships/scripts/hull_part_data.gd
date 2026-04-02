class_name HullPartData
extends Resource

@export var name : String
@export var prefab : PackedScene

enum HullPartType {STRUCTURE, SAIL, FIN, ENGINE, TAIL, LONGSAIL, GASBAG, OTHER}

@export var type : HullPartType

@export_enum("Small", "Medium", "Large", "Extra Large") var size : int

@export var tall_both_ways : bool = false

func _to_string() -> String:
	return name
