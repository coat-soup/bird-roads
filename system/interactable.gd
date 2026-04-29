extends Node3D
class_name Interactable

signal interacted

@export var prompt_text : String
@export var display_keycode : bool = true

var active := true


func observe() -> String:
	return prompt_text if active else ""


func interact():
	if not active:
		return
	
	interacted.emit()


func toggle_active(value: bool):
	active = value
