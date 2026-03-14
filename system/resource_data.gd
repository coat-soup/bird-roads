extends Node

var rooms : Array = []


func _init() -> void:
	load_resources(rooms, "res://ships/rooms/room_data/")


func load_resources(array : Array, path : String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
	
		while file != "":
			if file.ends_with(".tres"):
				var item = load(path + file)
				array.append(item)
			file = dir.get_next()
