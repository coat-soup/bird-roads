class_name AirshipPlayerController
extends Node

var movement : AirshipMovementManager
@export var mouse_sensetivity : float = 0.005

func _ready() -> void:
	movement = get_parent() as AirshipMovementManager
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	var dir : Vector3 = Vector3(Input.get_axis("right", "left"), Input.get_axis("crouch", "jump"), Input.get_axis("down", "up"))
	movement.thrust_input = dir.z
	movement.strafe_input = dir.x
	movement.lift_input = dir.y
	
	movement.roll_input = Input.get_axis("airship_roll_left", "airship_roll_right")
	if event is InputEventMouseMotion:
		movement.joystick_input += Vector2(-event.relative.x, event.relative.y) * mouse_sensetivity
		movement.joystick_input = movement.joystick_input.limit_length()
	
	$"../VJoy/Line2D".points[1] = movement.joystick_input * 50 * Vector2(-1,1)
	$"../VJoy/ColorRect".position = movement.joystick_input * 50 * Vector2(-1,1)


func _physics_process(delta: float) -> void:
	$"../VJoy/Label".text = "%0fm/s" % movement.linear_velocity.project(movement.global_basis.z).length()
