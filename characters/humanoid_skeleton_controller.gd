class_name HumanoidSkeletonController
extends Node3D

@onready var skeleton_3d: Skeleton3D = $Armature/Skeleton3D

@onready var head_target: Marker3D = $Pivot/HeadTarget
@onready var pivot: Marker3D = $Pivot
@export var look_target : Node3D
@export var character : Character
@onready var rh_two_bone_ik_3d: TwoBoneIK3D = $Armature/Skeleton3D/RHTwoBoneIK3D
@onready var rh_copy_transform_modifier_3d: CopyTransformModifier3D = $Armature/Skeleton3D/RHCopyTransformModifier3D
@onready var lh_two_bone_ik_3d: TwoBoneIK3D = $Armature/Skeleton3D/LHTwoBoneIK3D
@onready var lh_copy_transform_modifier_3d: CopyTransformModifier3D = $Armature/Skeleton3D/LHCopyTransformModifier3D
@onready var weapon_rt: RemoteTransform3D = $Pivot/WeaponRT

@export var clothes : Array[ClothesData]


func _ready() -> void:
	if character:
		character.perception_manager.perception_updated.connect(on_perception_updated)
		for data in clothes:
			data.add_clothes_to_character(character)
	else: for data in clothes:
			data.add_clothes_to_basemesh(self)


func on_perception_updated():
	if character.perception_manager.stimuli.size() > 0:
		look_target = character.perception_manager.get_main_target()
	else: look_target = null


func set_hand_ik_target(target : Node3D, left : bool = false):
	if !left:
		rh_two_bone_ik_3d.set_target_node(0, rh_two_bone_ik_3d.get_path_to(target))
		rh_copy_transform_modifier_3d.set_reference_node(0, rh_copy_transform_modifier_3d.get_path_to(target))
	else:
		lh_two_bone_ik_3d.set_target_node(0, lh_two_bone_ik_3d.get_path_to(target))
		lh_copy_transform_modifier_3d.set_reference_node(0, lh_copy_transform_modifier_3d.get_path_to(target))


func _process(delta: float) -> void:
	#head_target.global_position = GameManager.player.global_position
	
	if look_target:
		pivot.look_at(look_target.global_position, Vector3.UP, true)
	else:
		pivot.rotation = Vector3.ZERO
	
	if !character: return
	
	var target_rot : float = 0.0
	
	if character.velocity.length() > 0.1 and look_target:
		target_rot = lerp(character.global_basis.z.signed_angle_to(character.velocity, Vector3.UP), character.global_basis.z.signed_angle_to((look_target.global_position - character.global_position) * Vector3(1,0,1), Vector3.UP), 0.8)
	elif character.velocity.length() < 0.1 and look_target:
		target_rot = character.global_basis.z.signed_angle_to((look_target.global_position - character.global_position) * Vector3(1,0,1), Vector3.UP)
	else:
		target_rot = character.global_basis.z.signed_angle_to(character.velocity, Vector3.UP)
	
	
	rotation.y = rotate_toward(rotation.y, target_rot, delta * 5)
