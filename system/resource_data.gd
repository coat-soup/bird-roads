@tool
extends Node

var rooms : Array = []
var commodities : Array[Commodity]
var towns : Array[TownManager] # loaded from town nodes on init

func _init() -> void:
	load_resources(rooms, "res://ships/rooms/room_data/")
	load_resources(commodities, "res://world-sim/commodities/")


static func load_resources(array : Array, path : String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
	
		while file != "":
			if file.ends_with(".tres"):
				var item = load(path + file)
				array.append(item)
			file = dir.get_next()
