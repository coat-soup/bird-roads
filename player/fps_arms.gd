class_name FPSArms
extends Node3D

@onready var weapon_rt: RemoteTransform3D = $ArmRig/Skeleton3D/BoneAttachment3D/WeaponRT
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var sway_strength : float = 1.0
@export var player : Player

var mouse_input : Vector2
var extra_sway : Vector2

func _ready() -> void:
	player.movement_manager.jump_start.connect(add_jump_sway)
	player.movement_manager.jump_land.connect(add_jump_sway)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_input = event.relative * GameManager.player.movement_manager.sensetivity


func _process(delta: float) -> void:
	mouse_input = lerp(mouse_input, Vector2.ZERO, delta * 10)
	extra_sway = lerp(extra_sway, Vector2.ZERO, delta * 10)
	
	var sway = mouse_input + extra_sway
	
	rotation.x = lerp(rotation.x, -sway.y * sway_strength, delta * 10)
	rotation.y = lerp(rotation.y, sway.x * sway_strength - PI, delta * 10)
	rotation.z = lerp(rotation.z, Input.get_axis("left", "right") * sway_strength * 0.08, delta *  5)


func add_jump_sway():
	extra_sway.y = -0.2
