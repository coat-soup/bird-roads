extends Node3D
class_name CannonShell

signal impacted

@export var damage := 30
@export var radius := 0 ## 0 for direct impact, >0 for explosion

@export var speed := 100.0
@export var drop_rate := 10.0

@export var particles : PackedScene

var layer_mask := [1]
var ignore_list : Array[RID] = [self]

var velocity := Vector3.ZERO
var parent_velocity := Vector3.ZERO

var active = true


func _ready():
	velocity = transform.basis.z * speed


func _physics_process(delta: float) -> void:
	if active:
		var space_state = get_world_3d().direct_space_state
		
		var end = global_position + velocity * delta
		var query = PhysicsRayQueryParameters3D.create(global_position, end, Util.layer_mask(layer_mask))
		query.exclude = ignore_list
		
		var result := space_state.intersect_ray(query)
		
		if result:
			global_position = result.position
			handle_impact()
	
	global_position += (velocity + parent_velocity) * delta
	velocity.y -= drop_rate * delta
	look_at(global_position - velocity)


func handle_impact():
	var particles : Node3D = preload("res://vfx/scenes/explosion_particles.tscn").instantiate()
	get_tree().root.add_child(particles)
	particles.global_position = global_position
	queue_free()
