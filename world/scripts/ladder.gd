@tool
class_name Ladder
extends Node3D

const LADDER_SEGMENT = preload("uid://ceorue7173e6a")

@onready var area: Area3D = $Area
@onready var area_bottom: Area3D = $AreaBottom

@export_range(2, 100) var height : int = 2:
	set(value):
		height = value
		generate_ladder()

@export var force_side_on_top : bool = true

@export var collision_shape : CollisionShape3D
@export var area_shape : CollisionShape3D

var player_exited : bool = true


func _ready() -> void:
	if not Engine.is_editor_hint():
		area.body_entered.connect(on_body_entered)
		area.body_exited.connect(on_body_exited)
		area_bottom.body_entered.connect(on_body_entered_bottom)
	
	generate_ladder()


func generate_ladder():
	for child in $Segments.get_children(): child.queue_free()
	
	for i in range(height):
		var seg = LADDER_SEGMENT.instantiate()
		$Segments.add_child(seg)
		seg.owner = self
		seg.position.y = i
		
		
		collision_shape.shape = BoxShape3D.new()
		collision_shape.shape.size = Vector3(1,height,0.1)
		collision_shape.position.y = height/2.0
		
		area_shape.shape = BoxShape3D.new()
		area_shape.shape.size = Vector3(1,height,1)
		area_shape.position.y = height/2.0


func on_body_entered(body : Node3D):
	if not player_exited: return
	var player = body as Player
	if player:
		player_exited = false
		#snap_player_to_ladder(player)
		player.movement_manager.on_ladder = self


func on_body_exited(body : Node3D):
	var player = body as Player
	if player:
		if player.movement_manager.on_ladder:
			player.movement_manager.on_ladder = null
			player.velocity = global_basis.x * 5 * sign(-global_basis.x.dot(player.movement_manager.camera.global_basis.z)) + global_basis.y * 3
		#await get_tree().create_timer(0.5).timeout
		player_exited = true


func on_body_entered_bottom(body : Node3D):
	if player_exited: return
	var player = body as Player
	if player: player.movement_manager.on_ladder = null


func global_position_to_ladder_ratio(pos : Vector3) -> float:
	var ladder_displacement = (global_position - pos).project(global_basis.z * height)
	return ladder_displacement.length() / float(height)


func snap_global_position_to_ladder(pos : Vector3) -> Vector3:
	return pos
	return global_position + global_basis.z * global_position_to_ladder_ratio(pos) * height
