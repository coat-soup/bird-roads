class_name WeaponManager
extends Node3D

@export var character : Character
@export var cur_weapon : Weapon
@export var skeleton : HumanoidSkeletonController
@export var player : Player


func _ready() -> void:
	if skeleton and cur_weapon:
		skeleton.set_hand_ik_target(cur_weapon.hand_ik_target)
		if(cur_weapon.left_hand_ik_target): skeleton.set_hand_ik_target(cur_weapon.left_hand_ik_target, true)
		skeleton.weapon_rt.remote_path = skeleton.weapon_rt.get_path_to(cur_weapon)


func try_fire_weapon():
	cur_weapon.fire()


func try_reload_weapon():
	if not cur_weapon.reloading and cur_weapon.cur_ammo < cur_weapon.magazine_size:
		cur_weapon.reload()
