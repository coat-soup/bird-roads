extends Control

@onready var actor: Actor = $".."
@onready var color_rect: ColorRect = $"../ColorRect"
@onready var name_label: Label = $"../NameLabel"


func _ready() -> void:
	await get_tree().process_frame
	actor.interacted_with_town.connect(on_interacted)
	color_rect.scale *= (actor.cargo_capacity/5.0)
	name_label.text = actor.ship_name

func on_interacted():
	$"../ColorRect".color = actor.held_cargo.debug_data_color if actor.held_cargo else Color.WHITE
