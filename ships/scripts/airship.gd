class_name Airship
extends Node3D

@export var actor_data : ActorData
@onready var movement: AirshipMovementManager = $Movement

var engines : Array[ShipComponent]
var control_surfaces : Array[ShipComponent]


func _init() -> void:
	if not actor_data:
		actor_data = ActorData.new()
