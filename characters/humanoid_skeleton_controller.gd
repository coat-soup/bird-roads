extends Node3D

@onready var skeleton_3d: Skeleton3D = $Armature/Skeleton3D

@onready var head_target: Marker3D = $Pivot/HeadTarget
@onready var pivot: Marker3D = $Pivot
@export var look_target : Node3D
@export var character : Character


func _ready() -> void:
	if character: character.perception_manager.perception_updated.connect(on_perception_updated)


func on_perception_updated():
	if character.perception_manager.stimuli.size() > 0:
		look_target = character.perception_manager.stimuli[0].source_node
	else: look_target = null


func _process(delta: float) -> void:
	#head_target.global_position = GameManager.player.global_position
	if look_target:
		pivot.look_at(look_target.global_position + Vector3.UP * 0.35, Vector3.UP, true)
	else:
		pivot.rotation = Vector3.ZERO
	if character and character.velocity != Vector3.ZERO:
		rotation.y = character.global_basis.z.signed_angle_to(character.velocity, Vector3.UP)
