class_name DialogueSaveLoadPopup
extends Control

@onready var dialogue_editor: DialogueEditor = $".."

@onready var label: Label = $Label

@onready var text_edit: TextEdit = $TextEdit
@onready var action_button: Button = $ActionButton
@onready var cancel_button: Button = $CancelButton

var save_state : bool = true

func _ready() -> void:
	action_button.pressed.connect(on_action_pressed)
	cancel_button.pressed.connect(on_cancel_pressed)


func on_action_pressed():
	if text_edit.text != "":
		if save_state: dialogue_editor.save_dialogue(text_edit.text)
		else: dialogue_editor.load_dialogue(text_edit.text)
		close()
	else:
		text_edit.placeholder_text = "Please enter a name!"


func on_cancel_pressed():
	text_edit.text = ""
	close()


func open_save_menu():
	print("ENABLING SAVER")
	label.text = "SAVE DIALOGUE"
	action_button.text = "SAVE"
	save_state = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP


func open_load_menu():
	print("ENABLING LOADER")
	label.text = "LOAD DIALOGUE"
	action_button.text = "LOAD"
	save_state = false
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP


func close():
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
