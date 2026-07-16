class_name GenericDialogueNode
extends DialogueEditorNode


func get_json_dict(connections_list : Array[Dictionary]) -> Dictionary:
	return {
		"type" : "generic_dialogue",
		"node_name" : name,
		"connections" : prune_connections(connections_list),
		"node_pos" : [position.x, position.y],
		"text" : $TextEdit.text,
		"clear_text" : $ClearOldTextButton.button_pressed
	}

func setup_from_json_dict(data : Dictionary):
	$TextEdit.text = data["text"]
	if data.has("clear_text"): $ClearOldTextButton.button_pressed = data["clear_text"]
