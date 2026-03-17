class_name ShipInteriorGenerator
extends Node3D

var rooms : Array[ShipRoom]
var room_datas : Array[ShipRoomData]


func _ready() -> void:
	generate()


func generate() -> void:
	for room in rooms:
		room.queue_free()
	rooms.clear()
	
	for c in get_children():
		var room_slot = c as ShipRoomSlot
		if room_slot:
			var room_data = pick_random_room(room_slot)
			rooms.append(room_slot.spawn_room(room_data))
			room_datas.append(room_data)


func pick_random_room(slot : ShipRoomSlot) -> ShipRoomData:
	var n_rooms = ResourceData.rooms.size()
	var random_start = randi() % n_rooms
	for i in range(n_rooms):
		var r = (random_start + i) % n_rooms
		if ResourceData.rooms[r] not in room_datas and slot.can_fit_room(ResourceData.rooms[r]):
			return ResourceData.rooms[r]
	push_error("Couldn't find room.")
	return null
