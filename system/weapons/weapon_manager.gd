class_name WeaponManager
extends Node3D

@export var character : Character
@export var cur_weapon : Weapon
@export var skeleton : HumanoidSkeletonController

func _ready() -> void:
	if skeleton and cur_weapon:
		skeleton.set_hand_ik_target(cur_weapon.hand_ik_target)
		skeleton.weapon_rt.remote_path = skeleton.weapon_rt.get_path_to(cur_weapon)

func try_fire_weapon():
	if not cur_weapon.waiting_to_fire: cur_weapon.fire()
