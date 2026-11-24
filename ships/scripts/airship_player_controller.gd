class_name AirshipPlayerController
extends Controllable

@export var movement : AirshipMovementManager
@export var mouse_sensetivity : float = 0.005


func on_interacted():
	super.on_interacted()
	GameManager.ui.toggle_airship_hud(controlled)


func _input(event: InputEvent) -> void:
	if !controlled: return
	
	if event.is_action_pressed("interact"): on_interacted()
	
	var dir : Vector3 = Vector3(Input.get_axis("right", "left"), Input.get_axis("crouch", "jump"), Input.get_axis("down", "up"))
	movement.thrust_input = dir.z
	movement.strafe_input = dir.x
	movement.lift_input = dir.y
	
	movement.roll_input = Input.get_axis("airship_roll_left", "airship_roll_right")
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_pressed("freelook"):
			camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * 0.004)
			camera.rotate_object_local(Vector3.UP, -event.relative.x * 0.004)
			camera.rotation.z = 0
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		else:
			movement.joystick_input += Vector2(-event.relative.x, event.relative.y) * mouse_sensetivity
			movement.joystick_input = movement.joystick_input.limit_length()
			GameManager.ui.update_virtual_joystick(movement.joystick_input)

func _process(delta: float) -> void:
	var cam_return_speed = delta * 2
	if not Input.is_action_pressed("freelook"): camera.rotation = Vector3(lerp_angle(camera.rotation.x, 0, cam_return_speed), lerp_angle(camera.rotation.y, PI, cam_return_speed), 0)
