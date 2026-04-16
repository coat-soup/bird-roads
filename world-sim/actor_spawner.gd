extends Node2D

const ACTOR = preload("uid://s15urpdpp2mo")

@export var amount : int

func _ready() -> void:
	for i in range(amount):
		var actor_data = ActorData.new()
		var actor : Node2D = ACTOR.instantiate()
		actor.data = actor_data
		add_child(actor)
		var town = Resources.towns.pick_random()
		actor.position = town.position + Vector2(randi() % 30, randi() % 30)
		actor.target = town
