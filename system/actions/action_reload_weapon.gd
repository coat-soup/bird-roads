class_name ActionReloadWeapon
extends AIAction


func get_weight(character : Character) -> float:
	var p : float = float(character.weapon_manager.cur_weapon.cur_ammo) / float(character.weapon_manager.cur_weapon.magazine_size)
	if p > 0.5 : return 0
	return remap(p, 0, 0.5, 1, 0.0)


func run_action(character : Character):
	character.weapon_manager.try_reload_weapon()
