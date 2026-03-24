class_name ShipExteriorGenerator
extends Node

func _ready() -> void:
	var chosen_one : int = randi() % get_child_count()
	for i in range(get_child_count()):
		get_child(i).visible = i == chosen_one
