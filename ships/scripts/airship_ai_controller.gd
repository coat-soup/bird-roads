class_name AirshipAIController
extends AIController


@export var movement : AirshipMovementManager

var target : Vector3


func tick():
	if active:
		movement.thrust_input = lerp(0.0, 1.0, min(1.0, movement.global_position.distance_to(target)/100.0))
		movement.lift_input = clamp(target.y - movement.global_position.y, 0.0, 1.0)
		movement.joystick_input = Vector2(
			movement.global_basis.z.signed_angle_to(target - movement.global_position, movement.global_basis.y),
			movement.global_basis.z.signed_angle_to(target - movement.global_position, movement.global_basis.x)
		)
		movement.roll_input = clamp(-movement.rotation.z, -1.0, 1.0)
		ticked.emit()
	
	await get_tree().create_timer(1.0/tick_rate).timeout
	tick()
