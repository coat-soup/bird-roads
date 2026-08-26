class_name ClothesData
extends Resource

@export var clothes_name : StringName
@export var mesh : PackedScene

@export var colour_options : Array[Color]

enum ClothesType {HAIR, BEARD, MUSTACHE, CHEST, CHEST_OUTER, LEGS, FEET, HANDS}
@export var type : ClothesType

@export var albedo : Texture
@export var normal : Texture
const CHARACTER_SHADER = preload("res://characters/clothes/character_shader.gdshader")


func add_clothes_to_character(character : Character):
	var clothes = mesh.instantiate()
	character.skeleton_controller.add_child(clothes)
	
	var meshes : Array[MeshInstance3D]
	recursive_get_meshes(clothes, meshes)
	
	var mat = ShaderMaterial.new()
	mat.shader = CHARACTER_SHADER
	mat.set_shader_parameter("albedo_tex", albedo)
	mat.set_shader_parameter("normal_tex", normal)
	
	
	for mesh in meshes:
		mesh.skeleton = mesh.get_path_to(character.skeleton_controller.skeleton_3d)
		mesh.material_override = mat
		mesh.set_instance_shader_parameter("modulate_override", colour_options.pick_random())


func add_clothes_to_basemesh(skeleton_controller : HumanoidSkeletonController):
	var clothes = mesh.instantiate()
	skeleton_controller.add_child(clothes)
	
	var meshes : Array[MeshInstance3D]
	recursive_get_meshes(clothes, meshes)
	
	var mat = ShaderMaterial.new()
	mat.shader = CHARACTER_SHADER
	mat.set_shader_parameter("albedo_tex", albedo)
	mat.set_shader_parameter("normal_tex", normal)
	
	for mesh in meshes:
		mesh.skeleton = mesh.get_path_to(skeleton_controller.skeleton_3d)
		mesh.material_override = mat
		mesh.set_instance_shader_parameter("modulate_override", colour_options.pick_random())


func recursive_get_meshes(node : Node, mesh_array : Array[MeshInstance3D]):
	var mesh = node as MeshInstance3D
	if mesh: mesh_array.append(mesh)
	for child in node.get_children(): recursive_get_meshes(child, mesh_array)
