@tool

class_name TownData
extends Resource

@export var name : String

@export_tool_button("Load Commodity Resources") var load_commodity_resources_action = load_commodity_dictionary

## Key: Commodity name
## x: supply
## y: target_supply
@export var commodity_states : Dictionary[String, Vector2i]

## Key: Commodity name
## value: amount of added/subtraced commodity per tick
@export var commodity_generators : Dictionary[String, int]


func _init() -> void:
	load_commodity_dictionary()


func load_commodity_dictionary():
	var commodities : Array[Commodity]
	ResourceData.load_resources(commodities, "res://world-sim/commodities/")
	
	for c in commodities:
		if !commodity_states.keys().has(c.name):
			commodity_states[c.name] = Vector2i(0,0)
