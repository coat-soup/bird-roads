extends Node3D
class_name CannonShell

signal impacted

@export var damage := 30
@export var radius := 2 ## 0 for direct impact, >0 for explosion

@export var speed := 100.0
@export var drop_rate := 10.0

@export var particles : PackedScene

@export var expiration_time : float = 10.0

var layer_mask := [1]
var ignore_list : Array[RID] = [self]

var velocity := Vector3.ZERO
var parent_velocity := Vector3.ZERO

var active = true


func _ready():
	velocity = transform.basis.z * speed
	
	await get_tree().create_timer(expiration_time).timeout
	handle_impact()


func _physics_process(delta: float) -> void:
	if active:
		var space_state = get_world_3d().direct_space_state
		
		var end = global_position + velocity * delta
		var query = PhysicsRayQueryParameters3D.create(global_position, end, Util.layer_mask(layer_mask))
		query.exclude = ignore_list
		
		var result := space_state.intersect_ray(query)
		
		if result:
			global_position = result.position
			handle_impact(result)
	
	global_position += (velocity + parent_velocity) * delta
	velocity.y -= drop_rate * delta
	look_at(global_position - velocity)


func handle_impact(hit_result = null):
	var particles : Node3D = preload("res://vfx/scenes/explosion_particles.tscn").instantiate()
	get_tree().root.add_child(particles)
	particles.global_position = global_position
	
	if radius <= 0 and hit_result:
		var health : Health = hit_result.collider as Health
		if health: health.take_damage(damage)
	elif radius > 0:
		var space_state = get_world_3d().direct_space_state
	
		var collision_shape = PhysicsShapeQueryParameters3D.new()
		collision_shape.shape = SphereShape3D.new()
		collision_shape.shape.radius = radius
		collision_shape.transform.origin = position
		#collision_shape.collision_mask = layer_mask([1,2,4,5,6])
	
		var results = space_state.intersect_shape(collision_shape)
		var healths : Array[Health]
		
		for result in results:
			var health = result.collider as Health
			if health and !healths.has(health): healths.append(health)
		for health in healths: health.take_damage(damage)
	queue_free()
