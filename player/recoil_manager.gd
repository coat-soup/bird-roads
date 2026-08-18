class_name RecoilManager
extends Node3D

@export var weapon_manager : WeaponManager
@export var return_speed : float = 5.0

var target_r = Vector3.ZERO

var heat : float = 0


func _process(delta: float) -> void:
	rotation_degrees = lerp(rotation_degrees, target_r, delta * 50)
	target_r = lerp(target_r, Vector3.ZERO, delta * return_speed * (1.0 - heat))
	if heat > 0: heat = max(0, heat - delta * 5)


func do_recoil(amount : float):
	heat = min(1.2, heat + amount)
	target_r.x += amount
	target_r.y += randf_range(-amount/3.0, amount/3.0)
	target_r.z = randf_range(-amount/3.0, amount/3.0)
