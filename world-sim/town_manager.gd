class_name TownManager
extends Node2D

@export var town_data : TownData

const TICK_INTERVAL = 10.0

func _init() -> void:
	Resources.towns.append(self)

func _ready() -> void:
	$TownName.text = town_data.name
	tick()


func tick():
	for c in town_data.commodity_generators.keys():
		town_data.change_commodity(c, town_data.commodity_generators[c])
	await get_tree().create_timer(TownManager.TICK_INTERVAL / WorldSim.sim_speed).timeout
	tick()


func sell_to_town(commodity : Commodity, amount : int) -> float:
	var money : int = commodity.base_value * amount
	town_data.change_commodity(commodity, amount)
	return money


func buy_from_town(commodity : Commodity, amount : int) -> float:
	var money : int = commodity.base_value * amount
	town_data.change_commodity(commodity, -amount)
	return money

func _to_string() -> String:
	return town_data.name
