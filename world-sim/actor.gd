class_name Actor
extends Node2D

signal interacted_with_town

var data : ActorData

enum ActorState {DOCKED, MOVING, LONGSAIL, COMBAT}
var state : ActorState

var held_cargo : Commodity
var prev_cargo : Commodity

var target : TownManager

var ship_name : String


func _ready() -> void:
	WorldSim.actors.append(self)
	
	if not target: target = Resources.towns.pick_random()
	state = ActorState.MOVING
	held_cargo = null


func _physics_process(delta: float) -> void:
	if state == ActorState.DOCKED: return
	
	position += (target.position - position).normalized() * delta * data.speed * WorldSim.sim_speed
	if position.distance_to(target.position) < 10:
		interact_with_town(target)


func interact_with_town(town : TownManager):
	state = ActorState.DOCKED
	
	if held_cargo:
		town.sell_to_town(held_cargo, data.cargo_capacity)
		held_cargo = null
	
	await get_tree().create_timer(randf_range(0.5, 3.0)/WorldSim.sim_speed).timeout
	
	var best_trade = pick_best_action()
	if best_trade[0]: target.buy_from_town(best_trade[0], data.cargo_capacity)
	held_cargo = best_trade[0]
	target = best_trade[1]
	prev_cargo = held_cargo
	
	#print(ship_name, " going to ", target, " with ", held_cargo)
	
	state = ActorState.MOVING
	interacted_with_town.emit()


func pick_best_trade(start_town : TownManager, end_town : TownManager = null, disallow_prev = false) -> Array:
	var pairs : Array[Array]
	var weights : Array[float]
	
	for town in Resources.towns:
		if town == start_town: continue
		if end_town: town = end_town
		
		for c in Resources.commodities:
			if start_town.town_data.commodity_states[c].x < start_town.town_data.commodity_states[c].y * 0.8: continue
			if disallow_prev and c == prev_cargo: continue
			
			var buy_price = start_town.town_data.local_commodity_value(c) * c.base_value * data.cargo_capacity
			var sell_price = town.town_data.local_commodity_value(c) * c.base_value * data.cargo_capacity
			var distance_penalty = pow(0.66, town.position.distance_to(start_town.position) / 800)
			var value : float = (sell_price - buy_price) * distance_penalty
			#print(town, " ", c, " local value: ", town.town_data.local_commodity_value(c))
			
			if value > 0:
				pairs.append([c, town, value])
				weights.append(value)
		
		if end_town: break
	
	if len(weights) == 0: return [null, null, 0]
	return pairs[RandomNumberGenerator.new().rand_weighted(weights)]


func pick_best_action() -> Array:
	var best_destination : TownManager
	var best_value : float = -INF
	
	var pairs : Array[Array]
	var weights : Array[float]
	
	for town in Resources.towns:
		if town == target: continue
		
		var trade_1 = pick_best_trade(target, town, true)
		var trade_2 = pick_best_trade(town)
		
		var value = trade_1[2] + trade_2[2] * 0.5
		
		#print("at %s; checking %10s from %15s to %15s: value %5d; %10s on the way val %5d; total value %5d"
		#% [target, trade_2[0], town, trade_2[1], trade_2[2], trade_1[0], trade_1[2], value])
		
		if value > best_value:
			best_value = value
			best_destination = town
		
		pairs.append([trade_1[0], town])
		weights.append(value)
	
	if len(weights) == 0: return [null, best_destination]
	var choice = pairs[RandomNumberGenerator.new().rand_weighted(weights)]
	return choice if best_value > 0 else [null, choice[1]]
