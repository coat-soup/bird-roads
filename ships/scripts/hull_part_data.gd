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
## -1 if undamageable
@export var durability : int = -1

func _to_string() -> String:
	return name


func _init(t : HullPartType = HullPartType.STRUCTURE, s : int = 0, p : int = 4, d : int = -1) -> void:
	type = t
	size = s
	power = p
	durability = d
