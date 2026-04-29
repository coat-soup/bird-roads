class_name Player
extends CharacterBody3D

@export var active : bool = true
@export var movement_manager : PlayerMovement

@export var debug_mode : bool = false


func _ready() -> void:
	GameManager.player = self
