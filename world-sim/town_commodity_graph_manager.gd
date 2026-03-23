extends Node

@export var town_holder : Node

var towns : Array[TownManager]
var charts : Array[LineChart]


func _ready() -> void:
	for child in town_holder.get_children():
		var town_manager = child as TownManager
		if town_manager:
			towns.append(town_manager)
			var chart = LineChart.new(town_manager.town_data.name, 500, 200, 100)
			charts.append(chart)
			add_child(chart)
			for c in ResourceData.commodities:
				chart.add_line(c.debug_data_color, false)
				chart.add_line(c.debug_data_color, true)
		
	tick()


func tick():
	for i in range(len(towns)):
		for j in range(len(ResourceData.commodities)):
			# supply line
			charts[i].lines[j*2].push_data(towns[i].town_data.commodity_states[ResourceData.commodities[j].name].x)
			charts[i].lines[j*2].draw()
			# desired supply line
			charts[i].lines[j*2+1].push_data(towns[i].town_data.commodity_states[ResourceData.commodities[j].name].y)
			charts[i].lines[j*2+1].draw()
			
			print("%s %s (supply: %d, target:%d)" % [towns[i].town_data.name, ResourceData.commodities[j].name, towns[i].town_data.commodity_states[ResourceData.commodities[j].name].x, towns[i].town_data.commodity_states[ResourceData.commodities[j].name].y])
	
	await get_tree().create_timer(TownManager.TICK_INTERVAL).timeout
	tick()
