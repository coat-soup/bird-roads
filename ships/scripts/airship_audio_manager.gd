class_name AirshipAudioManager
extends Node3D

@onready var airship: Airship = $"../.."

@onready var engine_sounds: AudioStreamPlayer3D = $EngineSounds

var engine_intensity : float = 0

func _ready() -> void:
	engine_sounds.play()

func _process(delta: float) -> void:
	engine_intensity = lerp(engine_intensity, abs(airship.movement.thrust_input), delta * 2.0)
	engine_sounds.pitch_scale = lerp(0.01, 1.5, engine_intensity)
	engine_sounds.volume_db = lerp(-50.0, 5.0, engine_intensity)
