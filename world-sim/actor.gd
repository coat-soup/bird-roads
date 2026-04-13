class_name Actor
extends Node2D

signal interacted_with_town

enum ActorState {DOCKED, MOVING, LONGSAIL, COMBAT}
var state : ActorState

@export var speed : float = 50
@export var cargo_capacity : int = 5

var held_cargo : Commodity

var target : TownManager


func _ready() -> void:
	speed += randf_range(-10,10)
	cargo_capacity += randi_range(-3,3)
	
	if not target: target = Resources.towns.pick_random()
	state = ActorState.MOVING
	held_cargo = null


func _physics_process(delta: float) -> void:
	position += (target.position - position).normalized() * delta * speed * WorldSim.sim_speed
	if position.distance_to(target.position) < 10 and state == ActorState.MOVING:
		interact_with_town(target)


func interact_with_town(town : TownManager):
	state = ActorState.DOCKED
	
	if held_cargo:
		town.sell_to_town(held_cargo, cargo_capacity)
		held_cargo = null
	
	await get_tree().create_timer(randf_range(0.5, 3.0)).timeout
	
	var best_trade = pick_best_action()
	if best_trade[0]: target.buy_from_town(best_trade[0], cargo_capacity)
	held_cargo = best_trade[0]
	target = best_trade[1]
	
	state = ActorState.MOVING
	interacted_with_town.emit()


func pick_best_trade(start_town : TownManager, end_town : TownManager = null) -> Array:
	var best_commodity : Commodity
	var best_destination : TownManager
	var best_value : int
	
	var pairs : Array[Array]
	var weights : Array[float]
	
	for town in Resources.towns:
		if town == start_town or (end_town and town != end_town): continue
		
		for c in Resources.commodities:
			var buy_price = start_town.town_data.local_commodity_value(c) * c.base_value * cargo_capacity
			var sell_price = town.town_data.local_commodity_value(c) * c.base_value * cargo_capacity
			var fuel_price = town.position.distance_to(start_town.position) / 10
			var value = sell_price - buy_price - fuel_price
			
			if value > 0:
				pairs.append([c, town])
				weights.append(value)
			
			if best_commodity == null or value > best_value:
				best_commodity = c
				best_destination = town
				best_value = value
	
	#if len(weights) == 0: return [null, best_destination]
	#return pairs[RandomNumberGenerator.new().rand_weighted(weights)]
	
	return [best_commodity, best_destination, best_value]


func pick_best_action() -> Array:
	var best_destination : TownManager
	var best_value : int
	
	var pairs : Array[Array]
	var weights : Array[float]
	
	for town in Resources.towns:
		if town == target: continue
		
		var trade_1 = pick_best_trade(target, town)
		var trade_2 = pick_best_trade(town)
		
		var value = trade_1[2] + trade_2[2]
		
		if best_destination == null or value > best_value:
			best_value = value
			best_destination = trade_1[1]
		
		if value > 0 or true:
			pairs.append([trade_1[0], trade_1[1]])
			weights.append(value)
	
	if len(weights) == 0: return [null, best_destination]
	var choice = pairs[RandomNumberGenerator.new().rand_weighted(weights)]
	return choice if best_value > 0 else  [null, choice[1]]
