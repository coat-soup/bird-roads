extends Node

var cur_waypoint : int = 0
@export var waypoints : Array[Node3D]
@onready var ai_controller: AirshipAIController = $".."


func _ready() -> void:
	ai_controller.ticked.connect(on_tick)


func on_tick():
	ai_controller.target = waypoints[cur_waypoint].global_position
	if ai_controller.movement.global_position.distance_to(waypoints[cur_waypoint].global_position) < 50.0 : cur_waypoint = (cur_waypoint + 1) % len(waypoints)
