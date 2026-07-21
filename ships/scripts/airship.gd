class_name Airship
extends Node3D

@export var actor_data : ActorData
@onready var movement: AirshipMovementManager = $Movement

var engines : Array[ShipComponent]
var control_surfaces : Array[ShipComponent]

## 0-1 percentage of how many active engines/propellers are working and not broken
var thrust_ratio : float = 1.0
## 0-1 percentage of how many active control surfaces are working and not broken
var turn_ratio : float = 1.0


func _init() -> void:
	if not actor_data:
		actor_data = ActorData.new()


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
