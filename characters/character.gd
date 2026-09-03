class_name Character
extends CharacterBody3D

@export var movement_manager : CharacterMovement
@export var nav_agent : NavigationMeshAgent
@export var speed : float = 5
@export var behaviour_manager : CharacterBehaviourManager
@export var perception_manager : AIPerceptionManager
@export var health : Health
@export var weapon_manager : WeaponManager
@export var skeleton_controller : HumanoidSkeletonController

@export var debug_immortal : bool = false

@export var squad_id : int = 2


func _ready() -> void:
	health.died.connect(die)
	
	if debug_immortal:
		health.max_health = 1000000
		health.cur_health = health.max_health
		health.damaged.connect(on_debug_immortal_take_damage)


func on_debug_immortal_take_damage():
	health.cur_health = health.max_health


func die():
	queue_free()
