@tool
class_name CSGToStaticBodies
extends Node3D

@export_tool_button("Make Static Bodies", "Callable") var generate_action = execute
@export_flags_3d_physics var layers

func execute():
	for child in get_children():
		var csgbox = child as CSGBox3D
		if csgbox:
			if csgbox.get_child_count() > 0 and csgbox.get_child(0) is StaticBody3D: csgbox.get_child(0).queue_free()
			
			var body = StaticBody3D.new()
			body.collision_layer = layers
			csgbox.add_child(body)
			body.owner = owner
			
			var col_shape = CollisionShape3D.new()
			col_shape.shape = BoxShape3D.new()
			col_shape.shape.size = csgbox.size
			body.add_child(col_shape)
			col_shape.owner = owner
