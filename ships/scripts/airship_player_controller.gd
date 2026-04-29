class_name AirshipPlayerController
extends Interactable

@export var movement : AirshipMovementManager
@export var mouse_sensetivity : float = 0.005

@export var controlled : bool = false
@export var camera : Camera3D


func _ready() -> void:
	interacted.connect(on_interacted)


func _input(event: InputEvent) -> void:
	if !controlled: return
	
	if event.is_action_pressed("interact"): on_interacted()
	
	var dir : Vector3 = Vector3(Input.get_axis("right", "left"), Input.get_axis("crouch", "jump"), Input.get_axis("down", "up"))
	movement.thrust_input = dir.z
	movement.strafe_input = dir.x
	movement.lift_input = dir.y
	
	movement.roll_input = Input.get_axis("airship_roll_left", "airship_roll_right")
	if event is InputEventMouseMotion:
		movement.joystick_input += Vector2(-event.relative.x, event.relative.y) * mouse_sensetivity
		movement.joystick_input = movement.joystick_input.limit_length()
		GameManager.ui.update_virtual_joystick(movement.joystick_input)


func on_interacted():
	print("interacted. active: ", active, " curcontrolled: ", controlled)
	controlled = !controlled
	GameManager.player.active = !controlled
	GameManager.ui.toggle_airship_hud(controlled)
	
	if active:
		active = false
		camera.make_current()
	else:
		GameManager.player.movement_manager.camera.make_current()
		await get_tree().create_timer(0.3).timeout
		active = true
