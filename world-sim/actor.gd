class_name Actor
extends Node2D

@export var speed : float = 50
@export var cargo_capacity : int = 5

var target : TownManager


func _ready() -> void:
	target = Resources.towns.pick_random()


func _physics_process(delta: float) -> void:
	position += (target.position - position).normalized() * delta * speed
	if position.distance_to(target.position) < 10:
		target = Resources.towns.pick_random()
