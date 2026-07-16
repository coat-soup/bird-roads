class_name DialogueTrigger
extends Node

@export var dialogue_name : String

@export var interactable_trigger : Interactable


func _ready() -> void:
	if interactable_trigger: interactable_trigger.interacted.connect(trigger)


func trigger():
	GameManager.ui.dialogue.start_dialogue(dialogue_name)
