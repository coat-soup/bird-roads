class_name Cannon
extends Node3D

@export var turn_speed : float = 4
@export var fire_rate : float = 3

@export var yaw_obj : Node3D
@export var pitch_obj : Node3D

var target_rotation : Vector3

@export var pitch_min : float = -30
@export var pitch_max : float = 40

func _ready() -> void:
	target_rotation = Vector3(pitch_obj.rotation.x, yaw_obj.rotation.x, 0)

func fire():
	pass


func _process(delta: float) -> void:
	yaw_obj.rotation.y += clamp(wrapf(target_rotation.y - yaw_obj.rotation.y, -PI, PI) * 10, -1, 1) * delta * turn_speed
	pitch_obj.rotation.x += clamp(wrapf(target_rotation.x - pitch_obj.rotation.x, -PI, PI) * 10, -1, 1) * delta * turn_speed
	pitch_obj.rotation.x = clamp(pitch_obj.rotation.x, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
