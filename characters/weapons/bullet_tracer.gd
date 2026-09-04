extends Node3D
class_name BulletTracer

@export var scale_curve : Curve

static var velocity : float = 200.0

var lifetime : float
var age : float

var start_pos : Vector3
var end_pos : Vector3

var base_scale : Vector3

const BULLET_TRACER = preload("uid://0kbrkirls16l")

@onready var mesh: MeshInstance3D = $Mesh


static func create(start : Vector3, end : Vector3) -> BulletTracer:
	var tracer : BulletTracer = BULLET_TRACER.instantiate()
	
	tracer.lifetime = start.distance_to(end)/velocity
	tracer.start_pos = start
	tracer.end_pos = end
	
	return tracer


func _ready() -> void:
	base_scale = mesh.scale
	global_position = start_pos
	look_at(end_pos)


func _process(delta: float) -> void:
	age += delta
	
	global_position += -global_basis.z * velocity * delta
	
	mesh.scale = base_scale * scale_curve.sample(age/lifetime)
	
	if age >= lifetime:
		queue_free()
