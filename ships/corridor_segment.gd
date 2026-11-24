@tool
class_name CorridorSegment
extends Node3D

const CORRIDOR_WALL = preload("uid://cljk54oehp7uw")
const CORRIDOR_OPENING = preload("uid://slm1u6ktdt8w")
const CORRIDOR_FLOOR = preload("uid://b6wrrpa5wo3a5")
const CORRIDOR_FLOOR_OPEN = preload("uid://dy3q4rhy4412j")
const CORRIDOR_ROOF = preload("uid://1tlqj63cov2c")
const CORRIDOR_ROOF_OPEN = preload("uid://b5d8lghil430q")


@export var front_open : bool = true:
	set(value):
		front_open = value
		generate()

@export var back_open : bool = true:
	set(value):
		back_open = value
		generate()

@export var right_open : bool:
	set(value):
		right_open = value
		generate()

@export var left_open : bool:
	set(value):
		left_open = value
		generate()


@export var top_open : bool:
	set(value):
		top_open = value
		generate()

@export var bottom_open : bool:
	set(value):
		bottom_open = value
		generate()


var airship : Airship


func generate():
	for child in get_children():
		child.queue_free()
	
	var walls = [back_open, right_open, front_open, left_open]
	for i in range(4):
		var wall = (CORRIDOR_OPENING if walls[i] else CORRIDOR_WALL).instantiate()
		add_child(wall)
		wall.owner = self
		wall.rotation.y = PI/2 * (i if walls[i] else i - 1) # i - 1 because model is rotated
	
	var roof = (CORRIDOR_ROOF_OPEN if top_open else CORRIDOR_ROOF).instantiate()
	add_child(roof)
	roof.owner = self
	
	var floor = (CORRIDOR_FLOOR_OPEN if bottom_open else CORRIDOR_FLOOR).instantiate()
	add_child(floor)
	floor.owner = self
