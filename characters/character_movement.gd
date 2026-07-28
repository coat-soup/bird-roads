class_name CharacterMovement
extends Node3D

@export var character : Character
@export var agent : NavigationMeshAgent

@onready var floorcast: RayCast3D = $Floorcast

var time_in_air : float = 0


func _ready() -> void:
	agent.finished_path.connect(on_finished_path)


func on_finished_path():
	await get_tree().create_timer(1.0).timeout
	while len(agent.path) == 0:
		agent.random_path()


func _physics_process(delta: float) -> void:
	var direction : Vector3 = Vector3.ZERO
	var next_node = agent.get_next_node_in_path()
	
	if next_node:
		direction = ((next_node.global_position - character.global_position) * Vector3(1,0,1)).normalized()
	else: direction = Vector3.ZERO
	
	if floorcast.get_collider():
		time_in_air = 0
		if floorcast.get_collider() != character.get_parent():
			character.reparent(floorcast.get_collider())
	else:
		time_in_air += delta
		if time_in_air > 1.5 and character.get_parent() != get_tree().root: character.reparent(get_tree().root)
	
	# gravity
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
	else:
		if direction:
			character.velocity.x = direction.x * character.speed
			character.velocity.z = direction.z * character.speed
		else:
			character.velocity.x = lerp(character.velocity.x, direction.x * character.speed, delta * 10)
			character.velocity.z = lerp(character.velocity.z, direction.z * character.speed, delta * 10)
	
	character.move_and_slide()
