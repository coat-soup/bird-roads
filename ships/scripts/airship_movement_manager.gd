class_name AirshipMovementManager
extends RigidBody3D

@export var airship : Airship

@export var acceleration : float = 5.0
@export var angular_speed : float = 0.5
@export var angular_acceleration : float = 50.0

@export var max_roll : float = 20.0
@export var max_pitch : float = 20.0

var thrust_input : float = 0
var lift_input : float = 0
var strafe_input : float = 0

var joystick_input : Vector2
var roll_input : float = 0

@export var rotation_speed_curve : Curve
@export var rotation_correction_curve : Curve
@export var rotation_force_curve : Curve


func _physics_process(delta: float) -> void:
	apply_central_force(global_basis.x * acceleration * strafe_input * 0.4)
	apply_central_force(global_basis.y * acceleration * lift_input * 0.4)
	if get_directional_speed_ratio() <= 1.0: apply_central_force(global_basis.z * acceleration * thrust_input)
	
	
	var local_vel = global_basis.inverse() * angular_velocity
	
	var j = joystick_input.limit_length(1.0) if joystick_input.length() > 0.1 else Vector3.ZERO
	
	var overturn = Vector2(
		abs(rad_to_deg(rotation.x))/(max_pitch * rotation_speed_curve.sample(get_directional_speed_ratio())),
		abs(rad_to_deg(rotation.z))/(max_roll * rotation_speed_curve.sample(get_directional_speed_ratio())))
	
	var roll_force = rotation_force_curve.sample(min(1.0, overturn.y)) if sign(roll_input) == sign(rotation.z) else 1.0
	var pitch_force = rotation_force_curve.sample(min(1.0, overturn.x)) if sign(j.y) == sign(rotation.x) else 1.0
	
	apply_torque(global_basis.x * j.y * angular_acceleration * pitch_force)
	apply_torque(global_basis.y * j.x * angular_acceleration * 2)
	apply_torque(global_basis.z * roll_input * angular_acceleration * roll_force * 0.2)
	
	
	apply_torque(global_basis.x * -sign(rotation.x) * rotation_correction_curve.sample(overturn.x) * 50)
	apply_torque(global_basis.z * -sign(rotation.z) * rotation_correction_curve.sample(overturn.y) * 10)
	
	var veldiff : Vector3 = Vector3(
		max(0, get_directional_speed_ratio(global_basis.x, airship.actor_data.speed * 0.4) - strafe_input),
		max(0, get_directional_speed_ratio(global_basis.y, airship.actor_data.speed * 0.4) - lift_input),
		max(0, get_directional_speed_ratio() - thrust_input))
	apply_central_force(global_basis * (global_basis.inverse() * -linear_velocity * veldiff))


func get_directional_speed_ratio(axis : Vector3 = global_basis.z, max_speed : float = airship.actor_data.speed) -> float:
	return linear_velocity.project(axis).length() / max_speed
