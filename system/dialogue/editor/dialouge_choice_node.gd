class_name DialogueChoiceNode
extends DialogueEditorNode

@onready var add_choice_button: Button = $AddChoiceButton


func _ready() -> void:
	super._ready()
	
	add_choice_button.pressed.connect(add_choice)


func add_choice():
	var new_choice = $Choice.duplicate()
	add_child(new_choice)
	var index = get_child_count() - 2
	move_child(new_choice, index)
	(new_choice.get_child(0) as TextEdit).text = ""
	(new_choice.get_child(0) as TextEdit).placeholder_text = "Dialogue Option " + str(index+1)
	set_slot(index, false, 0, Color.WHITE, true, 0, Color.WHITE)


func remove_choice(index):
	pass


func get_json_dict(connections_list : Array[Dictionary]) -> Dictionary:
	var option_texts : Array[String] = []
	for c in get_children():
		var text_edit = c.get_child(0) as TextEdit if c.get_child_count() > 0 else null
		if c as HBoxContainer and text_edit:
			option_texts.append(text_edit.text)
	
	return {
		"type" : "dialogue_choice",
		"node_name" : name,
		"connections" : prune_connections(connections_list),
		"node_pos" : [position.x, position.y],
		"option_texts" : option_texts
	}


func setup_from_json_dict(data : Dictionary):
	for i in range(len(data["option_texts"]) - 2): add_choice()
	for i in range(len(data["option_texts"])):
		var choice = get_child(i)
		var text_edit = choice.get_child(0) as TextEdit if choice.get_child_count() > 0 else null
		if choice as HBoxContainer and text_edit: text_edit.text = data["option_texts"][i]
