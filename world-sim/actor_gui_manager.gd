extends Control

@export var debug_faction_colours : Array[Color]

@onready var actor: Actor = $".."
@onready var color_rect: ColorRect = $"../Clickbox/ColorRect"
@onready var name_label: Label = $"../NameLabel"
@onready var info_box: Control = $"../InfoBox"

@onready var cargo_label: Label = $"../InfoBox/GridContainer/CargoLabel"
@onready var power_label: Label = $"../InfoBox/GridContainer/PowerLabel"
@onready var speed_label: Label = $"../InfoBox/GridContainer/SpeedLabel"
@onready var extra_label: Label = $"../InfoBox/GridContainer/ExtraLabel"
@onready var faction_occupation_label: Label = $"../InfoBox/FactionOccupationLabel"
@onready var info_name_label: Label = $"../InfoBox/NameLabel"
@onready var clickbox: Control = $"../Clickbox"


var is_hovered: bool = false


func _enter_tree() -> void:
	await get_tree().process_frame
	actor.interacted_with_town.connect(on_interacted)
	color_rect.scale *= (actor.data.cargo_capacity/5.0)
	name_label.text = actor.data.ship_name
	
	
	info_name_label.text = actor.data.ship_name
	cargo_label.text = "%d cargo" % actor.data.cargo_capacity
	power_label.text = "%d power" % actor.data.combat_power
	speed_label.text = "%d speed" % actor.data.speed
	extra_label.text = "other"
	
	faction_occupation_label.text = str(ActorData.Faction.keys()[actor.data.faction]).to_lower() + " " + str(ActorData.Profession.keys()[actor.data.profession]).to_lower()
	color_rect.color = debug_faction_colours[actor.data.faction]


func _ready() -> void:
	info_box.visible = false
	clickbox.mouse_entered.connect(on_mouse_entered)
	clickbox.mouse_exited.connect(on_mouse_exited)


func on_interacted():
	pass
	#color_rect.color = actor.held_cargo.debug_data_color if actor.held_cargo else Color.WHITE


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("fire_1"):
		info_box.visible = is_hovered


func on_mouse_entered():
	is_hovered = true


func on_mouse_exited():
	is_hovered = false
