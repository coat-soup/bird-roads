class_name CannonAIController
extends Node

signal ticked

@export var active : bool = false
@onready var cannon: Cannon = $".."

const tick_rate : float = 12

@export var target : Node3D


func _ready() -> void:
	tick()
	
	await get_tree().create_timer(0.5).timeout
	
	var airships = get_tree().get_nodes_in_group("Airship")
	var closest : Airship = airships[0]
	for airship in airships:
		airship = airship as Airship
		if closest == cannon.airship or (airship != cannon.airship and airship.movement.global_position.distance_to(cannon.global_position) < closest.movement.global_position.distance_to(cannon.global_position)):
			closest = airship
	target = closest.movement

func tick():
	if active and target:
		var pos = cannon.muzzle_point.global_position
		var shell_speed := 100.0 # TODO: take from actual data object
		var drop_speed := 10.0
		var parent_vel : Vector3 = cannon.airship.movement.linear_velocity if cannon.airship else Vector3.ZERO
		var target_pos := target.global_position
		var target_vel : Vector3 = (target as RigidBody3D).linear_velocity if (target as RigidBody3D) else Vector3.ZERO
		
		
		var rel_vel = target_vel - parent_vel
		var future = target_pos
		var angle := 0.0
		var flight_time := 0.0
		
		for i in 6:
			var delta = future - pos
			var horizontal_dist = Vector2(delta.x, delta.z).length()
			var vertical_dist = delta.y
			
			angle = solve_ballistic_angle(horizontal_dist, vertical_dist, shell_speed, drop_speed)
			if is_nan(angle): break
			
			var horizontal_speed = shell_speed * cos(angle)
			flight_time = horizontal_dist / max(horizontal_speed, 0.01)
			future = target_pos + rel_vel * flight_time
		
		if not is_nan(angle):
			var delta = future - pos
			var horizontal = Vector3(delta.x, 0.0, delta.z).normalized()
			
			var launch_dir = horizontal * cos(angle)
			launch_dir.y = sin(angle)
			launch_dir = launch_dir.normalized()

			var local_dir = cannon.global_basis.inverse() * launch_dir
		
			var yaw = atan2(local_dir.x, local_dir.z)
			var pitch = -atan2(local_dir.y, Vector2(local_dir.x, local_dir.z).length())
		
			cannon.target_rotation = Vector2(pitch, yaw)
		
			cannon.fire()
		
		ticked.emit()
	
	await get_tree().create_timer(1.0/tick_rate).timeout
	tick()



func solve_ballistic_angle(horizontal_dist: float, vertical_dist: float, speed: float, gravity: float) -> float:
	var v2 = speed * speed
	
	var discriminant = v2 * v2 - gravity * (gravity * horizontal_dist * horizontal_dist + 2.0 * vertical_dist * v2)
	
	if discriminant < 0.0:
		return NAN
	
	# Lower trajectory
	return atan((v2 - sqrt(discriminant)) / (gravity * horizontal_dist))
