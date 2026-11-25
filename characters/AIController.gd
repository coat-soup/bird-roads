class_name AIController
extends Node

signal ticked
signal active_changed

const tick_rate : float = 12

var controlling_character : Character

@export var active : bool = false:
	set(value):
		active = value
		active_changed.emit()


func _ready() -> void:
	tick()


func tick():
	await get_tree().create_timer(1.0/tick_rate).timeout
	tick()


func set_active(character : Character):
	controlling_character = character
	active = true


func set_inactive():
	active = false
	controlling_character = null
