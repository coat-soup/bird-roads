class_name CannonAIController
extends AIController


@onready var cannon: Cannon = $".."

@export var target : Node3D
@export var subtarget : Node3D

var los : bool = false

var los_dist_forgiveness : float = 5 # NOTE: changes depending on target type, gunner skill, etc


func _ready() -> void:
	super._ready()
	await get_tree().create_timer(0.5).timeout
	
	if active: target_highest_threat()
	
	active_changed.connect(target_highest_threat)


func tick():
	n_ticked += 1
	
	if n_ticked % 5 == 0:
		target_highest_threat()
	
	if active and target:
		subtarget = get_airship_subtarget(target)
		los = has_los(subtarget if subtarget else target, cannon.get_world_3d().direct_space_state)
		DebugDraw3D.draw_line(cannon.muzzle_point.global_position, subtarget.global_position if subtarget else target.global_position, Color.GREEN if los else Color.RED, 1.0/tick_rate)
	else: los = false
	
	if active and target:
		var pos = cannon.muzzle_point.global_position
		var shell_speed := 100.0 # TODO: take from actual data object
		var drop_speed := 10.0
		var parent_vel : Vector3 = cannon.airship.movement.linear_velocity if cannon.airship else Vector3.ZERO
		var target_pos : Vector3 = subtarget.global_position if subtarget else target.global_position
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
			
			if los:
				cannon.fire()
				cannon.auto_fire = true
			else: cannon.auto_fire = false
		
		ticked.emit()
		
	else: cannon.auto_fire = false
	
	await get_tree().create_timer(1.0/tick_rate).timeout
	tick()



func solve_ballistic_angle(horizontal_dist: float, vertical_dist: float, speed: float, gravity: float) -> float:
	var v2 = speed * speed
	
	var discriminant = v2 * v2 - gravity * (gravity * horizontal_dist * horizontal_dist + 2.0 * vertical_dist * v2)
	
	if discriminant < 0.0:
		return NAN
	
	# Lower trajectory
	return atan((v2 - sqrt(discriminant)) / (gravity * horizontal_dist))


func target_highest_threat():
	var airships = get_tree().get_nodes_in_group("Airship")
	var targets : Array[Node] = airships
	
	var best_t = targets[0]
	var highest_threat = 0
	
	var space_state = cannon.get_world_3d().direct_space_state
	
	for _target in targets:
		if _target == cannon.airship: continue
		var t = get_target_threat(_target) if has_los(_target.movement, space_state) else 0.0
		if t > highest_threat:
			highest_threat = t
			best_t = _target
	
	var airship = best_t as Airship
	if airship and airship != cannon.airship: target = airship.movement



func get_airship_subtarget(target : Node3D) -> Node3D:
	var airship = target.get_parent_node_3d() as Airship
	var space_state = cannon.get_world_3d().direct_space_state
	if airship:
		for engine in airship.engines:
			if engine.health and engine.health.cur_health > 0:
				if has_los(engine.center_point if engine.center_point else engine, space_state):
					return engine.center_point if engine.center_point else engine
	return null


func has_los(_target : Node3D, space_state : PhysicsDirectSpaceState3D, angle_limited = true) -> bool:
	if angle_limited:
		var dir : Vector3 = _target.global_position - cannon.muzzle_point.global_position
		var yaw_angle : float = rad_to_deg(cannon.global_basis.z.signed_angle_to(dir, cannon.muzzle_point.global_basis.y))
		var pitch_angle : float = rad_to_deg(cannon.global_basis.z.signed_angle_to(dir, cannon.muzzle_point.global_basis.x))
		if abs(yaw_angle) > cannon.yaw_range or pitch_angle > cannon.pitch_max or pitch_angle < cannon.pitch_min - 10: return false
	
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(cannon.muzzle_point.global_position, _target.global_position, Util.layer_mask([1,2,4,5,6] if (_target as AirshipMovementManager) else [1,2,5,6]), cannon.ray_self_exclude_list))
	
	if (not result or
		(result.collider == _target or result.collider.get_parent_node_3d() == _target) or 
		result.position.distance_to(_target.global_position) < los_dist_forgiveness):
		return true
	else: return false


func get_target_threat(_target : Node3D) -> float:
	var threat : float = 0
	
	var airship = _target as Airship
	if airship:
		for engine in airship.engines:
			if engine.health and engine.health.cur_health > 0: threat += 1
		
		threat *= 1.0 - min((cannon.global_position.distance_to(airship.movement.global_position) / 500), 1)
		if get_airship_subtarget(airship) == airship.movement: threat *= 0.3 # no vital components in los
	return threat
