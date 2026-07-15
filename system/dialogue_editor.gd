class_name DialogueEditor
extends Control

const GENERIC_DIALOGUE_NODE = preload("uid://cdc3h7rup5cyr")
const GENERIC_DIALOGUE_CHOICE_NODE = preload("uid://bvbyksccwwjgl")

@onready var graph: GraphEdit = $GraphEdit

@onready var saveload_popup: DialogueSaveLoadPopup = $SaveLoadPopup

@onready var save_button: Button = $TopBar/HBoxContainer/SaveButton
@onready var load_button: Button = $TopBar/HBoxContainer/LoadButton
@onready var add_node_button: Button = $TopBar/HBoxContainer/AddNodeButton
@onready var add_choice_button: Button = $TopBar/HBoxContainer/AddChoiceButton

var loaded_dialogue : String = ""


func _ready() -> void:
	save_button.pressed.connect(on_save_dialogue_pressed)
	load_button.pressed.connect(on_load_dialogue_pressed)
	add_node_button.pressed.connect(add_dialogue_node.bind(Vector2(500,500)))
	add_choice_button.pressed.connect(add_choice_node.bind(Vector2(500,500)))
	graph.connection_request.connect(on_connection_request)
	graph.disconnection_request.connect(on_disconnection_request)
	
	saveload_popup.close()


func _input(event: InputEvent) -> void:
	if saveload_popup.visible: return
	
	if Input.is_action_just_pressed("fire_1"):
		if Input.is_key_pressed(KEY_D): add_dialogue_node(get_viewport().get_mouse_position() - Vector2(100,100))
		if Input.is_key_pressed(KEY_C): add_choice_node(get_viewport().get_mouse_position() - Vector2(100,100))


func on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	if from_node == to_node: return
	graph.connect_node(from_node, from_port, to_node, to_port)


func on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	graph.disconnect_node(from_node, from_port, to_node, to_port)


func add_dialogue_node(pos : Vector2) -> GenericDialogueNode:
	var node : GenericDialogueNode = GENERIC_DIALOGUE_NODE.instantiate() as GenericDialogueNode
	node.position_offset = pos
	node.editor = self
	graph.add_child(node)
	return node


func add_choice_node(pos : Vector2) -> DialogueChoiceNode:
	var node : DialogueChoiceNode = GENERIC_DIALOGUE_CHOICE_NODE.instantiate() as DialogueChoiceNode
	node.position_offset = pos
	node.editor = self
	graph.add_child(node)
	return node


func on_save_dialogue_pressed():
	if loaded_dialogue == "": saveload_popup.open_save_menu()
	else: save_dialogue(loaded_dialogue)


func on_load_dialogue_pressed():
	saveload_popup.open_load_menu()


func rename_node(node : DialogueEditorNode, t : String) -> String:
	if t == "": return node.name
	var connections : Array[Dictionary] = graph.get_connection_list_from_node(node.name)
	for c in connections:
		graph.disconnect_node(c["from_node"], c["from_port"], c["to_node"], c["to_port"])
	var old_name = node.name
	node.name = t
	for c in connections:
		graph.connect_node(node.name if c["from_node"] == old_name else c["from_node"], c["from_port"], node.name if c["to_node"] == old_name else c["to_node"], c["to_port"])
	return node.name


func save_dialogue(dialogue_name : String):
	if dialogue_name == "" and loaded_dialogue == "": dialogue_name = "unsaved_dialogue_" + str(Time.get_time_string_from_system())
	print("saving dialogue ", loaded_dialogue)
	loaded_dialogue = dialogue_name
	
	var json : Dictionary
	
	var connection_list : Array[Dictionary] = graph.connections
	print(connection_list)
	for child in graph.get_children():
		var node : DialogueEditorNode = child as DialogueEditorNode
		if not node:
			print(child, " not a dialogue node")
			continue
		json[node.name] = node.get_json_dict(graph.get_connection_list_from_node(node.name))
	
	var filepath : String = "res://system/dialogue/savedata/" + dialogue_name + ".json"
	var file = FileAccess.open(filepath, FileAccess.ModeFlags.WRITE)
	var json_text = JSON.stringify(json, "\t")
	file.store_string(json_text)
	
	print("Dialogue saved:")
	print(JSON.stringify(json, "\t"))


func load_dialogue(dialogue_name : String):
	graph.clear_connections()
	for child in graph.get_children(): if child as DialogueEditorNode: child.queue_free()
	
	var filepath : String = "res://system/dialogue/savedata/" + dialogue_name + ".json"
	var file = FileAccess.open(filepath, FileAccess.ModeFlags.READ)
	
	if not file:
		print("File not found.")
		return
	
	var json_text = file.get_as_text()
	var json = JSON.new()
	json.parse(json_text)
	
	var connection_list : Array[Dictionary] = []
	
	for node_name in json.data:
		var node_data : Dictionary = json.data[node_name]
		var node : DialogueEditorNode = null
		var pos : Vector2 = Vector2(node_data["node_pos"][0], node_data["node_pos"][1])
		if node_data["type"] == "generic_dialogue": node = add_dialogue_node(pos)
		elif node_data["type"] == "dialogue_choice": node = add_choice_node(pos)
		
		for c in node_data["connections"]: connection_list.append(c)
		
		node.title_edit.text = rename_node(node, node_name)
		node.setup_from_json_dict(node_data)
	
	for c in connection_list:
		graph.connect_node(c["from_node"], c["from_port"], c["to_node"], c["to_port"])
	
	print("Dialogue loaded:")
	print(json_text)
