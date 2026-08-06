class_name Character
extends CharacterBody3D

@export var movement_manager : CharacterMovement
@export var nav_agent : NavigationMeshAgent
@export var speed : float = 5
@export var behaviour_manager : CharacterBehaviourManager
@export var perception_manager : AIPerceptionManager
@export var health : Health
@export var weapon_manager : WeaponManager


func _ready() -> void:
	health.died.connect(die)

## disabled for enemy combat debugging
func die():
	pass
	#queue_free()
