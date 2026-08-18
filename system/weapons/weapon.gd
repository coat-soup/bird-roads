class_name Weapon
extends Node3D

signal fired
signal reload_started

@export var damage : int = 12

@export var fire_rate : float = 5
var waiting_to_fire : bool = false
@export var magazine_size : int = 10
var cur_ammo : int = 1

@export var reload_time : float = 4.0
@export var range : float = 50.0
var reloading : bool = false

@export var weapon_manager : WeaponManager

@export var hand_ik_target : Node3D

@export var muzzle_point : Node3D
const MUZZLE_FLASH_PARTICLES = preload("uid://ejgkb3vtxnxe")
const BULLET_IMPACT_PARTICLES = preload("uid://big4223brww7b")

@export var weapon_name : String

@onready var animation_player: AnimationPlayer = $AnimationPlayer



func _ready() -> void:
	cur_ammo = magazine_size


func reload():
	if cur_ammo >= magazine_size or reloading: return
	reloading = true
	if animation_player:
		animation_player.speed_scale = animation_player.get_animation("Armature|reload").length / (reload_time)
		animation_player.play("Armature|reload")
	reload_started.emit()
	await get_tree().create_timer(reload_time).timeout
	animation_player.speed_scale = 1.0
	cur_ammo = magazine_size
	reloading = false


func fire():
	if cur_ammo <= 0 or waiting_to_fire or reloading: return
	
	cur_ammo -= 1
	
	if cur_ammo > 0: waiting_to_fire = true
	
	animation_player.play("Armature|" + weapon_name + "_fps_shoot")
	
	var muzzle_particles = MUZZLE_FLASH_PARTICLES.instantiate()
	muzzle_point.add_child(muzzle_particles)
	
	var result = get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		muzzle_point.global_position if not weapon_manager.player else weapon_manager.player.movement_manager.camera.global_position,
		((muzzle_point.global_position + muzzle_point.global_basis.z * range) if not weapon_manager.player else
		(weapon_manager.player.movement_manager.camera.global_position - weapon_manager.player.movement_manager.camera.global_basis.z * range)),
		Util.layer_mask([1,2]),
		[weapon_manager.character if weapon_manager.character else weapon_manager.player]
	))
	
	if result:
		var impact_particles : Node3D = BULLET_IMPACT_PARTICLES.instantiate()
		get_tree().root.add_child(impact_particles)
		impact_particles.global_position = result.position
		impact_particles.look_at(result.position + result.normal)
		
		var character : Character = result.collider as Character
		if character and character.health:
			character.health.take_damage(damage)
	
	fired.emit()
	
	if cur_ammo > 0:
		await get_tree().create_timer(1.0/fire_rate).timeout
		waiting_to_fire = false
		if (weapon_manager.character and 
		weapon_manager.character.behaviour_manager.action_manager.is_performing_action_by_name("fire_weapon")):
			fire()
