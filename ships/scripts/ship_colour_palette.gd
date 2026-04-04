class_name ShipColorPalette
extends Resource

@export_category("Hull")
@export var primary_hull_colours : Array[Color] = [Color.WHITE]
@export var secondary_hull_colours : Array[Color] = [Color.WHITE]
## Screws and bolts and things
@export var tertiary_hull_colours : Array[Color] = [Color.WHITE]

@export_category("Gasbags")
@export var primary_gasbag_colours : Array[Color] = [Color.WHITE]
@export var secondary_gasbag_colours : Array[Color] = [Color.WHITE]

@export_category("Sails")
@export var multiple_sail_colour_chance : float = 0.3
## Main canvas (for longsails too)
@export var primary_sail_colours : Array[Color] = [Color.WHITE]
## For detailing
@export var secondary_sail_colours : Array[Color] = [Color.WHITE]

@export_category("Hull parts")
@export var primary_hull_part_colours : Array[Color] = [Color.WHITE]
@export var secondary_hull_part_colours : Array[Color] = [Color.WHITE]


var hull_a : Color
var hull_b : Color
var hull_c : Color

var bag_a : Color
var bag_b : Color

var sail_a : Color
var sail_a2 : Color
var sail_b : Color

var part_a : Color
var part_b : Color


func resolve_palette():
	hull_a = primary_hull_colours.pick_random()
	hull_b = secondary_hull_colours.pick_random()
	hull_c = tertiary_hull_colours.pick_random()
	
	bag_a = primary_gasbag_colours.pick_random()
	bag_b = secondary_gasbag_colours.pick_random()
	
	sail_a = primary_sail_colours.pick_random()
	sail_a2 = primary_sail_colours.pick_random() if randf() < multiple_sail_colour_chance else sail_a
	sail_b = secondary_sail_colours.pick_random()
	
	part_a = primary_hull_part_colours.pick_random()
	part_b = secondary_hull_part_colours.pick_random()


func colourise_part(mesh : MeshInstance3D, type : HullPartData.HullPartType):
	match type:
		HullPartData.HullPartType.STRUCTURE:
			mesh.set_instance_shader_parameter("primary_color", hull_a)
			mesh.set_instance_shader_parameter("secondary_color", hull_b)
			mesh.set_instance_shader_parameter("tertiary_color", hull_c)
		HullPartData.HullPartType.GASBAG:
			mesh.set_instance_shader_parameter("primary_color", bag_a)
			mesh.set_instance_shader_parameter("secondary_color", bag_b)
		HullPartData.HullPartType.SAIL or HullPartData.HullPartType.LONGSAIL:
			mesh.set_instance_shader_parameter("primary_color", sail_a if randf() < 0.3 else sail_a2)
			mesh.set_instance_shader_parameter("secondary_color", sail_b)
		HullPartData.HullPartType.TAIL:
			mesh.set_instance_shader_parameter("primary_color", part_a)
			mesh.set_instance_shader_parameter("secondary_color", part_b)
			mesh.set_instance_shader_parameter("tertiary_color", sail_a)
		_:
			mesh.set_instance_shader_parameter("primary_color", part_a)
			mesh.set_instance_shader_parameter("secondary_color", part_b)
