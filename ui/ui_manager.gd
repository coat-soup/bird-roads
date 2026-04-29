extends Control

class_name UIManager

@onready var hud: Control = $HUD
@onready var options_panel: OptionsMenuManager = $OptionsPanel

@onready var interact_text: Label = $HUD/InteractText

@onready var health_bar: ProgressBar = $HUD/HealthBar

@onready var hitmarker: TextureRect = $HUD/CrosshairHolder/Hitmarker

@onready var mission_title_label: Label = $HUD/MissionPanel/MissionTitleLabel
@onready var mission_objectives_label: Label = $HUD/MissionPanel/MissionObjectivesLabel

@onready var airship_hud: Control = $AirshipHUD

@onready var vjoy_pip: Control = $AirshipHUD/VirtualJoystick/Pip
@onready var vjoy_line: Line2D = $AirshipHUD/VirtualJoystick/Line2D


var prompt_time_remaining := 0.0


func _ready():
	GameManager.ui = self
	
	hud.visible = true
	options_panel.visible = false
	
	interact_text.text = ""


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1: visible = !visible


func _process(delta: float) -> void:
	if prompt_time_remaining > 0:
		prompt_time_remaining -= delta
		if prompt_time_remaining <= 0:
			interact_text.text = ""


func set_interact_text(text: String = "", prefix_key := false):
	if prompt_time_remaining > 0: return
	var prefix = InputMap.action_get_events("interact")[0].as_text().split(" ")[0]
	interact_text.text = (("["+prefix+"] ") if prefix_key else "") + text


func display_prompt(prompt: String, time := 2.0):
	interact_text.text = prompt
	prompt_time_remaining = time


func update_health_bar(value: float):
	health_bar.value = value


func flash_hitmarker(dead : bool = false):
	hitmarker.modulate = Color.ORANGE if dead else Color.hex(0xffffff64)
	hitmarker.visible = true
	await get_tree().create_timer(0.1).timeout
	hitmarker.visible = false


func toggle_options_menu(value : bool):
	options_panel.visible = value
	hud.visible = !value
	if GameManager.player: GameManager.player.active = !value
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if value else Input.MOUSE_MODE_CAPTURED


func update_virtual_joystick(value : Vector2):
	vjoy_line.points[1] = value * 50 * Vector2(-1,1)
	vjoy_pip.position = value * 50 * Vector2(-1,1)

func toggle_airship_hud(value : bool):
	airship_hud.visible = value
