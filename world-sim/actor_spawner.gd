extends Node2D

const ACTOR = preload("uid://s15urpdpp2mo")

@export var amount : int
@export var spawn_point : Vector2

func _ready() -> void:
	for i in range(amount):
		var actor : Node2D = ACTOR.instantiate()
		add_child(actor)
		actor.position = spawn_point + Vector2(randi() % 30, randi() % 30)
