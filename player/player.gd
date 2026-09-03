class_name Player
extends CharacterBody3D

@export var active : bool = true
@export var movement_manager : PlayerMovement

@export var debug_mode : bool = false
@export var health : Health


func _ready() -> void:
	GameManager.player = self


func set_active(_active : bool):
	active = _active
	visible = active
	print("setting active to ", _active, " (", active, ")")
