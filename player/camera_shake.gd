extends Node3D
class_name CameraShake

@export var shake_reduction_rate := 1.0

@export var max_x := 10.0
@export var max_y := 10.0
@export var max_z := 5.0

@export var noise : FastNoiseLite
@export var noise_speed := 100.0

var cur_shake := 0.0

var time := 0.0

@onready var initial_rotation := rotation_degrees as Vector3

func _init() -> void:
	GameManager.camera_shake = self


func _process(delta):
	time += delta
	cur_shake = max(cur_shake - delta * shake_reduction_rate, 0.0)
	
	rotation_degrees.x = initial_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
	rotation_degrees.y = initial_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
	rotation_degrees.z = initial_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)


func shake(shake_amount : float):
	cur_shake = clamp(cur_shake + shake_amount, 0.0, 1.0)


func get_shake_intensity() -> float:
	return cur_shake * cur_shake


func get_noise_from_seed(_seed : int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
