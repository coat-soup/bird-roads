extends Node

var sim_speed : float = 20.0

var actors : Array[Actor]


func _ready() -> void:
	for c in Resources.commodities:
		var genbalance = 0
		for t in Resources.towns:
			if t.town_data.commodity_generators.keys().has(c):
				genbalance += t.town_data.commodity_generators[c]
		
		var color : String = "green" if genbalance == 0 else "red" if genbalance < 0 else "orange"
		print_rich("generator balance %12s: [color=%s]%2d[/color]" % [c, color, genbalance])
