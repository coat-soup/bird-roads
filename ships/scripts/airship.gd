class_name Airship
extends Node3D

@export var actor_data : ActorData
@onready var movement: AirshipMovementManager = $Movement

@export var nav_graph : NavigationGraph

var interior_generator : ShipInteriorGenerator
var exterior_generator : ShipExteriorGenerator

var engines : Array[ShipComponent]
var control_surfaces : Array[ShipComponent]
var weapon_platforms : Array[WeaponPlatform]
var crew_stations : Array[CrewStation]

## 0-1 percentage of how many active engines/propellers are working and not broken
var thrust_ratio : float = 1.0
## 0-1 percentage of how many active control surfaces are working and not broken
var turn_ratio : float = 1.0


func _init() -> void:
	if not actor_data:
		actor_data = ActorData.new()


func _ready() -> void:
	for child in movement.get_child(0).get_children():
		if not interior_generator:
			interior_generator = child as ShipInteriorGenerator
			if interior_generator: interior_generator.airship = self
		if not exterior_generator:
			exterior_generator = child as ShipExteriorGenerator
			if exterior_generator: exterior_generator.airship = self
	
	if not interior_generator: push_error("Airship ", name, " couldn't find interior generator.")
	if not exterior_generator: push_error("Airship ", name, " couldn't find exterior generator.")
	
	interior_generator.generate()
	exterior_generator.generate()
	
	if nav_graph:
		await get_tree().create_timer(0.5).timeout
		nav_graph.generate()


func calculate_thrust_ratio() -> float:
	var n_broken : float = 0.0
	var n_total : float = 0.0
	
	for engine in engines:
		n_total += engine.data.power
		if engine.broken: n_broken += engine.data.power
	
	thrust_ratio = (n_total-n_broken)/n_total
	return thrust_ratio


func calculate_turn_ratio() -> float:
	var n_broken : float = 0.0
	var n_total : float = 0.0
	var engine_modifier : float = 0.3
	
	for engine in engines:
		n_total += engine_modifier
		if engine.broken: n_broken += engine_modifier
	
	for control_surface in control_surfaces:
		n_total += 1
		if control_surface.broken: n_broken += 1
	
	turn_ratio = (n_total-n_broken)/n_total
	return turn_ratio
