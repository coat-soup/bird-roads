class_name ShipRoomPropConstraint
extends Node3D


@export var entrances : Array[Vector2i]
@export var new_pos : Vector3
@export var new_rot : Vector3
@export var parent_room : ShipRoom

@export var override_rotate_to_face_entrance : bool = false


func _ready() -> void:
	if not parent_room.generated:
		await parent_room.finished_generating
	
	if override_rotate_to_face_entrance:
		look_at(global_position - Vector3(parent_room.slot.entrance.x, 0, parent_room.slot.entrance.y) * parent_room.transform)
	elif parent_room.slot.entrance in entrances:
		position = new_pos
		rotation = Vector3(deg_to_rad(new_rot.x),deg_to_rad(new_rot.y),deg_to_rad(new_rot.z))
