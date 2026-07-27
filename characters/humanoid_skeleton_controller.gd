extends Node3D

@onready var skeleton_3d: Skeleton3D = $Armature/Skeleton3D

@onready var head_target: Marker3D = $Pivot/HeadTarget
@onready var pivot: Marker3D = $Pivot


func _process(delta: float) -> void:
	#head_target.global_position = GameManager.player.global_position
	pivot.look_at(GameManager.player.global_position + Vector3.UP * 0.35, Vector3.UP, true)
