@abstract class_name DialogueEditorNode
extends GraphNode

var editor : DialogueEditor
var title_edit : LineEdit


@abstract func get_json_dict(connections_list : Array[Dictionary]) -> Dictionary
@abstract func setup_from_json_dict(data : Dictionary)


@export var node_renameable : bool = true


func _ready() -> void:
	if node_renameable:
		var title_bar = get_titlebar_hbox()
		title_edit = LineEdit.new()
		title_bar.add_child(title_edit)
		title_edit.placeholder_text = "Nodename"
		title_edit.text = title
		title_edit.focus_exited.connect(try_update_title)
		title_edit.expand_to_text_length = true
		title_bar.move_child(title_edit, 0)
		(title_bar.get_child(1) as Label).horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		try_update_title()
	
	delete_request.connect(on_delete_request)


func on_delete_request():
	print("TRIED TO DELETE")


func prune_connections(connections_list : Array[Dictionary]) -> Array[Dictionary]:
	var connections : Array[Dictionary]
	
	for c in connections_list:
		if c["from_node"] == name:
			connections.append({
				"from_node": c["from_node"],
				"from_port": c["from_port"],
				"to_node": c["to_node"],
				"to_port": c["to_port"]
			})
	
	return connections


func try_update_title():
	if node_renameable:
		title_edit.text = editor.rename_node(self, title_edit.text)
