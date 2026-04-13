@tool

class_name TownData
extends Resource

@export var name : String

@export_tool_button("Load Commodity Resources") var load_commodity_resources_action = load_commodity_dictionary

## Key: Commodity name
## x: supply
## y: target_supply
@export var commodity_states : Dictionary[Commodity, Vector2i]

## Key: Commodity name
## value: amount of added/subtraced commodity per tick
@export var commodity_generators : Dictionary[Commodity, int]


func _init() -> void:
	load_commodity_dictionary()


func load_commodity_dictionary():
	var commodities : Array[Commodity]
	Resources.load_resources(commodities, "res://world-sim/commodities/")
	
	for c in commodities:
		if !commodity_states.keys().has(c):
			commodity_states[c] = Vector2i(0,0)

func change_commodity(commodity : Commodity, amount : int):
	commodity_states[commodity][0] += amount

func local_commodity_value(commodity : Commodity) -> int:
	return commodity_states[commodity][1] - commodity_states[commodity][0]
