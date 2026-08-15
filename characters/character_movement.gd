class_name CharacterMovement
extends Node3D

@export var character : Character
@export var agent : NavigationMeshAgent

@onready var floorcast: RayCast3D = $Floorcast

var time_in_air : float = 0

@onready var shin_cast: RayCast3D = $"../ShinCast"
@onready var head_cast: RayCast3D = $"../HeadCast"



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
			
			if abs(next_node.global_position.y - character.global_position.y) > 0.2 and shin_cast.is_colliding() and not head_cast.is_colliding():
				character.velocity.y += 5
		else:
			character.velocity.x = lerp(character.velocity.x, direction.x * character.speed, delta * 10)
			character.velocity.z = lerp(character.velocity.z, direction.z * character.speed, delta * 10)
	
	shin_cast.target_position = direction.normalized() * 0.6
	head_cast.target_position = shin_cast.target_position
	
	character.move_and_slide()
