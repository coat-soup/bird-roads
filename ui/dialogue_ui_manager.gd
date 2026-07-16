class_name DialogueUIManager
extends Control

signal requested_continue

@onready var name_label: Label = $NameBar/NameLabel
@onready var text_container: VBoxContainer = $TextContainer
@onready var continue_text: RichTextLabel = $ContinueText


var active_dialogue : Dictionary
var active_choice : int = 0
var max_choices : int = 0
var choice_start_child_index : int = 0


func _ready() -> void:
	visible = false
	
	continue_text.visible = false


func _input(event: InputEvent) -> void:
	if not visible: return
	
	if Input.is_action_just_pressed("fire_1"): requested_continue.emit()
	var scroll_dir = int(Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN)) - int(Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP))
	if scroll_dir != 0:
		update_active_choice(posmod(active_choice + scroll_dir, max_choices))


func start_dialogue(dialogue_name : String):
	var filepath : String = "res://system/dialogue/savedata/" + dialogue_name + ".json"
	var file = FileAccess.open(filepath, FileAccess.ModeFlags.READ)
	
	if not file:
		print("Dialogue file", dialogue_name, " not found.")
		return
	
	var json_text = file.get_as_text()
	var json = JSON.new()
	json.parse(json_text)
	
	active_dialogue = json.data
	
	visible = true
	
	for child in text_container.get_children(): child.queue_free()
	
	print("starting dialogue: ", active_dialogue)
	
	var start_node : String
	for node in active_dialogue: if active_dialogue[node]["type"] == "start":
		start_node = node
		break
	
	parse_dialogue_node(start_node)



func parse_dialogue_node(node_name : String):
	var node : Dictionary = active_dialogue[node_name]
	
	match node["type"]:
		"start": parse_dialogue_node(node["connections"][0]["to_node"])
		"end": close_dialogue()
		"generic_dialogue":
			clear_text(node["clear_text"])
			add_text(node["text"])
			continue_text.visible = true
			await requested_continue
			continue_text.visible = false
			parse_dialogue_node(node["connections"][0]["to_node"])
		"dialogue_choice":
			clear_text(node["clear_text"])
			max_choices = 0
			choice_start_child_index = text_container.get_child_count()
			for option_text in node["option_texts"]:
				add_text("> " + option_text)
				max_choices += 1
			update_active_choice(0)
			await requested_continue
			parse_dialogue_node(node["connections"][active_choice]["to_node"])
		_: pass


func update_active_choice(c : int):
	if max_choices < 2: return
	
	var prev : int = active_choice
	active_choice = c
	
	if prev != c:
		var prev_text : RichTextLabel = (text_container.get_child(prev + choice_start_child_index) if text_container.get_child_count() >= prev + choice_start_child_index else null) as RichTextLabel
		if prev_text: prev_text.modulate = Color.WHITE
	
	var cur_text : RichTextLabel = (text_container.get_child(active_choice + choice_start_child_index) if text_container.get_child_count() >= active_choice + choice_start_child_index else null) as RichTextLabel
	if cur_text: cur_text.modulate = Color.AQUA


func add_text(text : String):
	var rich_text : RichTextLabel = RichTextLabel.new()
	text_container.add_child(rich_text)
	rich_text.text = text
	rich_text.fit_content = true


func clear_text(do_clear : bool = true):
	if do_clear: for child in text_container.get_children():
		text_container.remove_child(child) # so child is instantly removed this frame (queue_free is async)
		child.queue_free()
	else:
		var spacer = text_container.add_spacer(false)
		spacer.size_flags_vertical = 0
		spacer.custom_minimum_size.y = 10


func close_dialogue():
	active_dialogue = {}
	visible = false
