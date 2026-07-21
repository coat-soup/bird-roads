class_name Health
extends Node

signal damaged
signal healed
signal died

@export var max_health : float
var cur_health : float

func _ready() -> void:
	cur_health = max_health


func take_damage(amount : float):
	cur_health = max(cur_health - amount, 0)
	
	damaged.emit()
	
	if cur_health <= 0:
		die()


func heal(amount : float):
	cur_health = min(cur_health + amount, max_health)
	
	healed.emit()


func die():
	died.emit()
