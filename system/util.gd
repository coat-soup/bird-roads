class_name Util

## Turns a list layer indices into corresponding layermask
## Eg. layer_mask([1,3]) returns 5 (101 in binary)
static func layer_mask(layers: Array) -> int:
	var mask := 0
	for layer in layers:
		mask |= (1 << (layer - 1))
	return mask

## Checks if mask contains layer
static func layer_in_mask(mask: int, layer: int) -> bool:
	return (mask & (1 << (layer - 1))) != 0


# COLLISION LAYER REPRESENTATIONS:
# 1 default
# 2 player (player should only ever have this)
# 3 interactable
# 4 airship physics interactors (should be on airship and terrain/large objects)


static func spawn_particles_for_time(position: Vector3, particles: PackedScene, parent: Node, time: float):
	var particles_obj = particles.instantiate()
	particles_obj.position = position
	parent.add_child(particles_obj)
	await particles_obj.get_tree().create_timer(time).timeout
	#particles_obj.queue_free()


static func random_point_in_sphere(radius : float, min_radius : float = 0.0, r : RandomNumberGenerator = RandomNumberGenerator.new()) -> Vector3:
	return (Vector3.UP * r.randf_range(min_radius, radius)).rotated(Vector3.RIGHT, r.randf_range(0, 2*PI)).rotated(Vector3.FORWARD, r.randf_range(0, 2*PI))

static func random_point_in_circle(radius : float, min_radius : float = 0.0, r : RandomNumberGenerator = RandomNumberGenerator.new()) -> Vector2:
	return (Vector2.UP * r.randf_range(min_radius, radius)).rotated(r.randf_range(0, 2*PI))

static func random_point_in_circle_3d(radius : float, min_radius : float = 0.0, r : RandomNumberGenerator = RandomNumberGenerator.new()) -> Vector3:
	var p_c : Vector2 = random_point_in_circle(radius, min_radius, r)
	return Vector3(p_c.x, 0, p_c.y)


static func get_rotation_towards(self_pos: Vector3, target_pos: Vector3) -> Vector3:
	var forward = (target_pos - self_pos).normalized()
	var up = Vector3.UP
	
	var right = up.cross(forward).normalized()
	up = forward.cross(right).normalized()
	
	var basis = Basis(right, up, forward)
	return basis.get_euler()
