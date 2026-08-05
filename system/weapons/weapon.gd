class_name Weapon
extends Node3D

@export var damage : int = 12

@export var fire_rate : float = 5
var waiting_to_fire : bool = false
@export var magazine_size : int = 10
var cur_ammo : int

@export var range : float = 50.0

@export var weapon_manager : WeaponManager

@export var hand_ik_target : Node3D

@export var muzzle_point : Node3D
const MUZZLE_FLASH_PARTICLES = preload("uid://ejgkb3vtxnxe")
const BULLET_IMPACT_PARTICLES = preload("uid://big4223brww7b")


func _ready() -> void:
	cur_ammo = magazine_size


func fire():
	waiting_to_fire = true
	cur_ammo -= 1
	
	var muzzle_particles = MUZZLE_FLASH_PARTICLES.instantiate()
	muzzle_point.add_child(muzzle_particles)
	
	var result = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		muzzle_point.global_position,
		muzzle_point.global_position + muzzle_point.global_basis.z * range,
		Util.layer_mask([1,2]),
		[weapon_manager.character]
	))
	
	if result:
		var impact_particles : Node3D = BULLET_IMPACT_PARTICLES.instantiate()
		get_tree().root.add_child(impact_particles)
		impact_particles.global_position = result.position
		impact_particles.look_at(result.position + result.normal)
		
		var character : Character = result.collider as Character
		if character and character.health:
			character.health.take_damage(damage)
	
	await get_tree().create_timer(1.0/fire_rate).timeout
	waiting_to_fire = false
