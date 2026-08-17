class_name PlayerWeaponManager
extends WeaponManager

@export var arms : FPSArms


func _ready() -> void:
	if player and cur_weapon:
		equip_weapon(cur_weapon)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("fire_1"): try_fire_weapon()
	if Input.is_action_just_pressed("reload"): try_reload_weapon()


func equip_weapon(weapon : Weapon):
	arms.weapon_rt.remote_path = arms.weapon_rt.get_path_to(weapon)
	weapon.weapon_manager = self
	
	weapon.fired.connect(on_weapon_fired)
	
	cur_weapon = weapon


func on_weapon_fired():
	var anim_name : String = cur_weapon.weapon_name + "_arms/arms_" + cur_weapon.weapon_name + "_shoot"
	print("animlength: ", arms.animation_player.get_animation(anim_name).length)
	arms.animation_player.speed_scale = arms.animation_player.get_animation(anim_name).length / (1.0 / cur_weapon.fire_rate)
	arms.animation_player.play(anim_name)
	await arms.animation_player.animation_finished
	arms.animation_player.speed_scale = 1.0
