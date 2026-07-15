class_name ShipComponent
extends Node3D

signal completed_setup

var data : HullPartData
var health : int

var airship : Airship

func setup(d : HullPartData, ship : Airship):
	data = d
	airship = ship
	if data.type == HullPartData.HullPartType.ENGINE: airship.engines.append(self)
	
	completed_setup.emit()
