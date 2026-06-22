class_name Controllable
extends Interactable

@export var controlled : bool = false
@export var camera : Camera3D


func _ready() -> void:
	interacted.connect(on_interacted)

func on_interacted():
	print("interacted. active: ", active, " curcontrolled: ", controlled)
	controlled = !controlled
	GameManager.player.active = !controlled
	
	if active:
		active = false
		camera.make_current()
	else:
		GameManager.player.movement_manager.camera.make_current()
		await get_tree().create_timer(0.3).timeout
		active = true
