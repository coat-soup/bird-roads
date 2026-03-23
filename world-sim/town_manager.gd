class_name TownManager
extends Node2D

@export var town_data : TownData

const TICK_INTERVAL = 0.5

func _init() -> void:
	ResourceData.towns.append(self)

func _ready() -> void:
	$TownName.text = town_data.name
	tick()


func tick():
	for c in ResourceData.commodities:
		town_data.commodity_states[c.name].x += randf() * 30 - 15
	await get_tree().create_timer(TownManager.TICK_INTERVAL).timeout
	tick()
