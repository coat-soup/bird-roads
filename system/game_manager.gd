extends Node

@export var ui : UIManager
@export var player : Player
@export var camera_shake : CameraShake

func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ESCAPE): get_tree().quit()
