class_name Actor
extends Node2D

enum ActorState {DOCKED, MOVING, LONGSAIL, COMBAT}
var state : ActorState

@export var speed : float = 50
@export var cargo_capacity : int = 5

var held_cargo : Commodity

var target : TownManager


func _ready() -> void:
	speed += randf_range(-10,10)
	
	if not target: target = Resources.towns.pick_random()
	state = ActorState.MOVING
	held_cargo = null


func _physics_process(delta: float) -> void:
	position += (target.position - position).normalized() * delta * speed
	if position.distance_to(target.position) < 10 and state == ActorState.MOVING:
		interact_with_town(target)


func interact_with_town(town : TownManager):
	state = ActorState.DOCKED
	
	if held_cargo:
		town.sell_to_town(held_cargo, cargo_capacity)
	
	await get_tree().create_timer(randf_range(0.5, 3.0)).timeout
	
	var best_trade = pick_best_trade()
	if best_trade[0]: target.buy_from_town(best_trade[0], cargo_capacity)
	target = best_trade[1]
	
	state = ActorState.MOVING


func pick_best_trade() -> Array:
	var best_commodity : Commodity
	var best_destination : TownManager
	var best_value_diff : int
	
	var pairs : Array[Array]
	var weights : Array[float]
	
	for town in Resources.towns:
		if town == target: continue
		
		for c in Resources.commodities:
			var value_diff = town.town_data.local_commodity_value(c) - target.town_data.local_commodity_value(c)
			value_diff -= town.position.distance_to(target.position) / 100
			if value_diff > 0:
				pairs.append([c, town])
				weights.append(value_diff)
			
			if best_commodity == null or value_diff > best_value_diff:
				best_commodity = c
				best_destination = town
				best_value_diff = value_diff
	
	if len(weights) == 0: return [null, best_destination]
	return pairs[RandomNumberGenerator.new().rand_weighted(weights)]
	
	return [best_commodity, best_destination]
