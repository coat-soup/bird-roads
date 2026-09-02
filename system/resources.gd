@tool
extends Node

var rooms : Array = []
var commodities : Array[Commodity]
var towns : Array[TownManager] # loaded from town nodes on init
var hull_parts : Array[HullPartData]
var hardpoints : Array[HardpointData]
var ship_weapons : Array[ShipWeaponData]
var ship_patterns : Array[Texture2D]


func _init() -> void:
	load_resources(rooms, "res://ships/rooms/room_data/")
	load_resources(commodities, "res://world-sim/commodities/")
	load_resources(hull_parts, "res://ships/hull-parts/data/")
	load_resources(hardpoints, "res://ships/hardpoints/data/")
	load_resources(ship_weapons, "res://ships/hardpoints/weapon_data/")
	load_resources(ship_patterns,"res://ships/textures/patterns/", ".png")
	print("patterns: ", ship_patterns)


static func load_resources(array : Array, path : String, file_ending : String = ".tres"):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
	
		while file != "":
			if file.ends_with(file_ending):
				var item = load(path + file)
				array.append(item)
			file = dir.get_next()
