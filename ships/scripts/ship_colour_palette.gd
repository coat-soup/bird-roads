class_name ShipColorPalette
extends Resource

@export_category("Hull")
@export var primary_hull_colours : Array[Color] = [Color.WHITE]
@export var secondary_hull_colours : Array[Color] = [Color.WHITE]
@export var underhull_colours : Array[Color] = [Color.WHITE]

@export_category("Bits")
@export var trim_colours : Array[Color] = [Color.WHITE]
@export var rivet_colours : Array[Color] = [Color.WHITE]

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
var underhull : Color

var bag_a : Color
var bag_b : Color

var sail_a : Color
var sail_a2 : Color
var sail_b : Color

var part_a : Color
var part_b : Color

var rivets : Color
var trim : Color


func resolve_palette(rand : RandomNumberGenerator):
	hull_a = primary_hull_colours[rand.randi() % primary_hull_colours.size()]
	hull_b = secondary_hull_colours[rand.randi() % secondary_hull_colours.size()]
	underhull = underhull_colours[rand.randi() % underhull_colours.size()]
	
	bag_a = primary_gasbag_colours[rand.randi() % primary_gasbag_colours.size()]
	bag_b = secondary_gasbag_colours[rand.randi() % secondary_gasbag_colours.size()]
	
	sail_a = primary_sail_colours[rand.randi() % primary_sail_colours.size()]
	sail_a2 = primary_sail_colours[rand.randi() % primary_sail_colours.size()] if rand.randf() < multiple_sail_colour_chance else sail_a
	sail_b = secondary_sail_colours[rand.randi() % secondary_sail_colours.size()]
	
	part_a = primary_hull_part_colours[rand.randi() % primary_hull_part_colours.size()]
	part_b = secondary_hull_part_colours[rand.randi() % secondary_hull_part_colours.size()]
	
	rivets = rivet_colours[rand.randi() % rivet_colours.size()]
	trim = trim_colours[rand.randi() % trim_colours.size()]


func colourise_part(mesh : MeshInstance3D, type : HullPartData.HullPartType):
	match type:
		HullPartData.HullPartType.STRUCTURE:
			mesh.set_instance_shader_parameter("pattern_id", 0)
			mesh.set_instance_shader_parameter("primary_color", hull_a)
			mesh.set_instance_shader_parameter("secondary_color", hull_b)
			mesh.set_instance_shader_parameter("tertiary_color", underhull)
		HullPartData.HullPartType.GASBAG:
			mesh.set_instance_shader_parameter("pattern_id", 0)
			mesh.set_instance_shader_parameter("primary_color", bag_a)
			mesh.set_instance_shader_parameter("secondary_color", bag_b)
		HullPartData.HullPartType.SAIL, HullPartData.HullPartType.LONGSAIL:
			mesh.set_instance_shader_parameter("primary_color", sail_a if randf() < 0.3 else sail_a2)
			mesh.set_instance_shader_parameter("secondary_color", sail_b)
		HullPartData.HullPartType.TAIL:
			mesh.set_instance_shader_parameter("primary_color", hull_a)
			mesh.set_instance_shader_parameter("secondary_color", part_b)
			mesh.set_instance_shader_parameter("tertiary_color", sail_a)
		_:
			mesh.set_instance_shader_parameter("primary_color", hull_a)
			mesh.set_instance_shader_parameter("secondary_color", part_b)
	
	mesh.set_instance_shader_parameter("quaternary_color", trim)
	mesh.set_instance_shader_parameter("quintary_color", rivets)
