@tool
class_name NavigationGraph
extends Area3D

@export_tool_button("Generate Graph", "Callable") var generate_action = generate

@export var spacing : float = 2.0
@export var vertical_spacing : float = 5.0
@export var step_height : float = 1.0

var nodes : Array[NavigationNode]


func generate():
	for node in nodes: if node and is_instance_valid(node): node.queue_free()
	nodes = []
	
	var space_state = get_world_3d().direct_space_state
	
	var collision_shapes : Array[CollisionShape3D]
	for child in get_children():
		var collision_shape = child as CollisionShape3D
		if collision_shape: collision_shapes.append(collision_shape)
	if collision_shapes.size() == 0: push_error("NavigationGraph must have a collision shape!")
	
	for shape in collision_shapes:
		# initial grid of nodes
		if shape.shape is BoxShape3D:
			var dims : Vector3i = Vector3i(round(shape.shape.size.x / spacing), round(shape.shape.size.y / vertical_spacing), round(shape.shape.size.z / spacing))
			for y in range(dims.y):
				print("ydim!")
				for z in range(dims.z):
					for x in range(dims.x):
						var origin_pos = (shape.global_position - shape.shape.size/2.0) + Vector3(x * spacing, y * vertical_spacing, z * spacing) + Vector3(0,vertical_spacing/2,0)
						var query = PhysicsRayQueryParameters3D.create(origin_pos, origin_pos - Vector3(0, vertical_spacing, 0))
						var result = space_state.intersect_ray(query)
						if not result:
							nodes.append(null)
							continue
						var node : NavigationNode = NavigationNode.new()
						add_child(node)
						node.owner = owner
						node.global_position = result.position + Vector3(0,0.7,0)
						nodes.append(node)
						node.grid_pos = Vector3i(x,y,z)
			
			# connect them
			for node in nodes:
				if not node: continue
				for x in range(-1,2):
					for y in range(-1,2):
						for z in range(-1,2):
							if x == 0 and y == 0 and z == 0: continue
							node.try_add_connection(nodes, dims, node.grid_pos + Vector3i(x,y,z), step_height)
	
	# handle invalid nodes
	for i in range(len(nodes)):
		var node : NavigationNode = nodes[i]
		if not node: continue
		var collision_shape = PhysicsShapeQueryParameters3D.new()
		collision_shape.shape = SphereShape3D.new()
		collision_shape.shape.radius = 0.1
		collision_shape.transform.origin = node.global_position
		collision_shape.collision_mask = Util.layer_mask([1])
		
		var results = space_state.intersect_shape(collision_shape)
		
		if len(results) > 0:
			collision_shape.transform.origin.y += 1
			node.clear_connections()
			node.queue_free()
			nodes[i] = null


func _process(delta: float) -> void:
	for node in nodes:
		if not node: continue
		DebugDraw3D.scoped_config().set_thickness(0.1)
		DebugDraw3D.draw_box(node.global_position, Quaternion.IDENTITY, Vector3.ONE * 0.2, Color.RED, true)
		DebugDraw3D.scoped_config().set_thickness(0.05)
		for c in node.connections:
			if not c or not is_instance_valid(c): continue
			DebugDraw3D.draw_line(node.global_position, c.global_position, Color.YELLOW)
		
