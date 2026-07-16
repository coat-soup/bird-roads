class_name DialogueEndNode
extends DialogueEditorNode


func get_json_dict(connections_list : Array[Dictionary]) -> Dictionary:
	return {
		"type" : "end",
		"node_name" : name,
		"connections" : prune_connections(connections_list),
		"node_pos" : [position.x, position.y]
	}

func setup_from_json_dict(data : Dictionary):
	pass
