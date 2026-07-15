class_name ShipEngineAnimator
extends AnimationPlayer

@export var ship_component : ShipComponent

var original_speed : float

func _ready() -> void:
	original_speed = speed_scale


func _physics_process(delta: float) -> void:
	if not ship_component.airship: return
	
	speed_scale = lerp(speed_scale, original_speed * ship_component.airship.movement.thrust_input, delta * 3)
