class_name ShipRoom
extends Node3D

signal finished_generating
var generated : bool = false

const tile_size : int = 4

const ROOM_CEILING = preload("uid://bsji6w8xncklj")
const ROOM_FLOOR = preload("uid://ceel7ils1uvds")
const ROOM_WALL_DOOR = preload("uid://b3wv5h0v3jtj6")
const ROOM_WALL_SOLID = preload("uid://t1cmy31vm0dq")
const ROOM_WALL_WINDOW = preload("uid://bgrm5vafw1jhf")

var slot : ShipRoomSlot


func generate(_slot : ShipRoomSlot):
	slot = _slot
	var offset = Vector3(tile_size / 2 if slot.spawned_room_data.size.x % 2 == 0 else 0,0,tile_size / 2 if slot.spawned_room_data.size.y % 2 == 0 else 0)
	for x in range(slot.size.x):# if slot.size.x == slot.spawned_room_data.size.x else slot.size.y):
		for y in range(slot.size.y):# if slot.size.y == slot.spawned_room_data.size.y else slot.size.x):
			var label = Label3D.new()
			label.text = "%d, %d" % [x,y]
			add_child(label)
			label.position = Vector3(x * tile_size,tile_size/2, y * tile_size) - offset
			
			var ceiling = ROOM_CEILING.instantiate()
			add_child(ceiling)
			ceiling.position = Vector3(x * tile_size,0, y * tile_size) - offset
			var floor = ROOM_FLOOR.instantiate()
			add_child(floor)
			floor.position = Vector3(x * tile_size,0, y * tile_size) - offset
			
			var di : int = -1
			for d in [Vector2i(0,-1), Vector2i(-1,0), Vector2i(1,0), Vector2i(0,1)]: # do all tile sides
				di += 1
				var p = d + Vector2i(x,y) #(Vector2i(x,y) if slot.spawned_room_data.size.x == slot.size.x else Vector2i(y,x))
				var s : Node3D = null
				if p == slot.entrance:
					#DOOR
					s = ROOM_WALL_DOOR.instantiate()
				elif p.x < 0 or p.y < 0 or p.x >= slot.spawned_room_data.size.x or p.y >= slot.spawned_room_data.size.y:
					#WALL
					s = ROOM_WALL_SOLID.instantiate()
				else:
					#INSIDE (EMPTY)
					pass
				if s:
					add_child(s)
					s.position = Vector3(x + d.x/2.0, 0, y + d.y/2.0) * tile_size - offset
					s.rotation.y = deg_to_rad([0,90,270,180][di])
	
	generated = true
	finished_generating.emit()
