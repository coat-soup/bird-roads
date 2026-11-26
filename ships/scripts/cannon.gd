class_name Cannon
extends Node3D

@export var turn_speed : float = 4
@export var fire_rate : float = 3
var time_to_fire : float = 0.0

@export var yaw_obj : Node3D
@export var pitch_obj : Node3D
@export var muzzle_point : Node3D

var target_rotation : Vector2

@export var pitch_min : float = -30
@export var pitch_max : float = 40

@export var yaw_range : float = 90

var airship : Airship

@export var ai_controller : CannonAIController

var ray_self_exclude_list : Array[RID]

var auto_fire : bool = false


func _ready() -> void:
	target_rotation = Vector2(pitch_obj.rotation.x, yaw_obj.rotation.x)
	
	var parent = get_parent_node_3d()
	while parent != null and not airship:
		airship = parent as Airship
		parent = parent.get_parent_node_3d()
	
	for child in get_children(true):
		var collider = child as CollisionObject3D
		if collider: ray_self_exclude_list.append(collider.get_rid())


func fire():
	if time_to_fire > 0: return
	
	time_to_fire = 1.0/fire_rate
	
	var shell : CannonShell = preload("res://ships/hardpoints/weapons/cannon_shell.tscn").instantiate()
	get_tree().root.add_child(shell)
	shell.global_position = muzzle_point.global_position
	shell.global_rotation = muzzle_point.global_rotation
	if airship:
		shell.parent_velocity = airship.movement.linear_velocity
		airship.movement.apply_force(-muzzle_point.global_basis.z * shell.damage/20, global_position - airship.movement.global_position)
	shell._ready()


func _process(delta: float) -> void:
	if time_to_fire > 0: time_to_fire -= delta
	elif auto_fire: fire()
	
	yaw_obj.rotation.y += clamp(wrapf(target_rotation.y - yaw_obj.rotation.y, -PI, PI) * 10, -1, 1) * delta * turn_speed
	yaw_obj.rotation.y = clamp(yaw_obj.rotation.y, deg_to_rad(-yaw_range), deg_to_rad(yaw_range))
	
	pitch_obj.rotation.x += clamp(wrapf(target_rotation.x - pitch_obj.rotation.x, -PI, PI) * 10, -1, 1) * delta * turn_speed
	pitch_obj.rotation.x = clamp(pitch_obj.rotation.x, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
