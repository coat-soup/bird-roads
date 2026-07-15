class_name ControlSurfaceAnimator
extends Node3D

@export var ship_component : ShipComponent
@export var turn_range : float = 30

var roll_mul : float
var pitch_mul : float
var yaw_mul : float

func _ready() -> void:
	if not ship_component.airship: await ship_component.completed_setup
	if not ship_component.airship.movement: await get_tree().process_frame
	
	var movement = ship_component.airship.movement
	var r = movement.to_local(global_position)
	var force = (movement.global_basis.inverse() * global_basis * Vector3.RIGHT ).normalized()
	var torque = r.cross(force)
	if torque.length() > 0.001: torque = torque.normalized()
	
	roll_mul  = torque.z
	pitch_mul = torque.x
	yaw_mul   = torque.y


func _physics_process(delta: float) -> void:
	if not ship_component.airship: return
	
	var pitch_effect = ship_component.airship.movement.joystick_input.y * pitch_mul
	var yaw_effect = ship_component.airship.movement.joystick_input.x * yaw_mul
	var roll_effect = ship_component.airship.movement.roll_input * roll_mul
	
	# var max = max(pitch_effect, yaw_effect, roll_effect)
	# var min = min(pitch_effect, yaw_effect, roll_effect)
	# var effect = max if (abs(max) > abs(min)) else min
	var effect = clamp(pitch_effect + yaw_effect + roll_effect, -1, 1)
	
	rotation.y = lerp(rotation.y, deg_to_rad(turn_range) * effect, delta * 5)
