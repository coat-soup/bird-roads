class_name ShipExteriorGenerator
extends Node

var rigging_points : Array[RiggingPoint]


func _ready() -> void:
	
	await get_tree().create_timer(0.5).timeout
	# do rigging
	for p in rigging_points:
		p.rig(rigging_points)
