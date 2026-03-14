class_name ShipRoomSlot
extends Marker3D

@export var size : Vector2i = Vector2i(1,1)
var spawned_room : ShipRoom


func can_fit_room(room_data : ShipRoomData) -> bool:
	return (room_data.size.x == size.x and room_data.size.y == size.y) or (room_data.size.y == size.x and room_data.size.x == size.y)


func spawn_room(room_data : ShipRoomData) -> ShipRoom:
	if not can_fit_room(room_data):
		push_error("Can't spawn room \"", room_data.name , "\" in slot ", name, " for ship ", get_parent_node_3d().name)
	
	print("Spawning room ", room_data.name, " at ", name)
	spawned_room = room_data.prefab.instantiate()
	add_child(spawned_room)
	if room_data.size.x != size.x:
		spawned_room.rotate(Vector3.UP, PI/2)
	
	return spawned_room
