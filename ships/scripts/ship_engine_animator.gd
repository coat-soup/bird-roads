class_name ShipEngineAnimator
extends AnimationPlayer

@export var ship_component : ShipComponent

var original_speed : float

func _ready() -> void:
	original_speed = speed_scale


func _physics_process(delta: float) -> void:
	if not ship_component.airship: return
	
	var target_speed : float = original_speed * ship_component.airship.movement.thrust_input
	if ship_component.broken: target_speed = 0
	speed_scale = lerp(speed_scale, target_speed, delta * 3)
