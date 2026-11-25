class_name CrewStation
extends Node3D

@export var controllable : Controllable
@export var ai_controller : AIController

var active_character : Character
var claimed_character : Character # characters can "claim" station while not currently active (so multiple npcs don't all try going to the same cannon)


func start_crewing(character : Character):
	active_character = character
	ai_controller.set_active(character)


func end_crewing(character : Character):
	active_character = null
	ai_controller.set_inactive()
