class_name RandomChild
extends Node3D

func resolve() -> void:
	var count = get_child_count()
	var choice : int = randi() % count
	for i in range(count-1, -1, -1):
		if i != choice: get_child(i).queue_free()
