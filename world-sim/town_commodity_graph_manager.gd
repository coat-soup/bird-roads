extends Node

@export var town_holder : Node

var towns : Array[TownManager]
var commodity_charts : Array[LineChart]
var haul_ratio_chart : LineChart

func _ready() -> void:
	for child in town_holder.get_children():
		var town_manager = child as TownManager
		if town_manager:
			towns.append(town_manager)
			var chart = LineChart.new(town_manager.town_data.name, 400, 200, 100)
			commodity_charts.append(chart)
			add_child(chart)
			for c in Resources.commodities:
				chart.add_line(c.debug_data_color, false)
				chart.add_line(c.debug_data_color, true)
	
	haul_ratio_chart = LineChart.new("Empty haul ratio", 1.0, 200, 100)
	add_child(haul_ratio_chart)
	for c in Resources.commodities:
		haul_ratio_chart.add_line(c.debug_data_color, false)
	haul_ratio_chart.add_line(Color.WHITE, false)
	
	tick()


func tick():
	for i in range(len(towns)):
		for j in range(len(Resources.commodities)):
			# supply line
			commodity_charts[i].lines[j*2].push_data(towns[i].town_data.commodity_states[Resources.commodities[j]].x, 200)
			commodity_charts[i].lines[j*2].draw()
			# desired supply line
			commodity_charts[i].lines[j*2+1].push_data(towns[i].town_data.commodity_states[Resources.commodities[j]].y, 200)
			commodity_charts[i].lines[j*2+1].draw()
			
			#print("%s %s (supply: %d, target:%d)" % [towns[i].town_data.name, Resources.commodities[j].name, towns[i].town_data.commodity_states[Resources.commodities[j]].x, towns[i].town_data.commodity_states[Resources.commodities[j]].y])
	
	var n_total = 0
	var hauls : Array[int]
	hauls.resize(Resources.commodities.size() + 1)
	for a in WorldSim.actors:
		if a.state != Actor.ActorState.DOCKED:
			n_total += 1
			hauls[Resources.commodities.find(a.held_cargo)] += 1
	
	for i in range(len(hauls)):
		haul_ratio_chart.lines[i].push_data(float(hauls[i])/float(n_total), 200)
		haul_ratio_chart.lines[i].draw()
	
	await get_tree().create_timer(0.5).timeout
	tick()
