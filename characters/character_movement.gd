class_name CharacterMovement
extends Node

@export var character : Character
@export var agent : NavigationMeshAgent


func _ready() -> void:
	agent.finished_path.connect(on_finished_path)


func on_finished_path():
	await get_tree().create_timer(1.0).timeout
	while len(agent.path) == 0:
		agent.random_path()


func _physics_process(delta: float) -> void:
	var next_node = agent.get_next_node_in_path()
	if next_node:
		character.velocity = ((next_node.global_position - character.global_position) * Vector3(1,0,1)).normalized() * character.speed
	else: character.velocity = Vector3.ZERO
	
	character.move_and_slide()
