class_name ShipRoomSlot
extends Marker3D

@export var size : Vector2i = Vector2i(1,1)
@export var entrance : Vector2i
var spawned_room : ShipRoom
var spawned_room_data : ShipRoomData


func can_fit_room(room_data : ShipRoomData) -> bool:
	return (room_data.size.x == size.x and room_data.size.y == size.y) or (room_data.size.y == size.x and room_data.size.x == size.y)


func spawn_room(room_data : ShipRoomData) -> ShipRoom:
	if not can_fit_room(room_data):
		push_error("Can't spawn room \"", room_data.name , "\" in slot ", name, " for ship ", get_parent_node_3d().name)
	
	spawned_room = room_data.prefab.instantiate()
	add_child(spawned_room)
	#if room_data.size.x != size.x:
		#spawned_room.rotate(Vector3.UP, -PI/2)
	
	spawned_room_data = room_data
	spawned_room.generate(self)
	
	return spawned_room
