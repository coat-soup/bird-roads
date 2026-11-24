class_name ShipInteriorGenerator
extends Node3D

signal finished_generating

var rooms : Array[ShipRoom]
var room_datas : Array[ShipRoomData]

var airship : Airship


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
		
		var corridor = c as CorridorSegment
		if corridor: corridor.airship = airship
	
	finished_generating.emit()


func pick_random_room(slot : ShipRoomSlot) -> ShipRoomData:
	var n_rooms = Resources.rooms.size()
	var random_start = randi() % n_rooms
	
	for x in range(2): # x = 0, don't duplicate rooms, x = 1 duplication ok (incase there aren't enough valid rooms)
		for i in range(n_rooms):
			var r = (random_start + i) % n_rooms
			if (x == 1 or Resources.rooms[r] not in room_datas) and slot.can_fit_room(Resources.rooms[r]):
				return Resources.rooms[r]
	
	push_error("Couldn't find room.")
	return null
