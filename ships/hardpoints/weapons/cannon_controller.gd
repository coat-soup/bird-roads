extends Controllable

@export var sensetivity : float = 0.005
@export var cannon : Cannon

func _input(event: InputEvent) -> void:
	if !controlled: return
	
	if event.is_action_pressed("interact"): on_interacted()
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera.rotation.y += (-event.relative.x * sensetivity)
		camera.rotation.x += (-event.relative.y * sensetivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		camera.rotation.z = 0
		cannon.target_rotation = Vector2(-camera.rotation.x + PI/2 * 0, camera.rotation.y + PI)
	
	if Input.is_action_just_pressed("fire_1"): cannon.fire()
	if Input.is_key_pressed(KEY_P): $"../AIController".active = true
