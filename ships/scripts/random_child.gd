class_name RandomChild
extends Node3D


func resolve(rand : RandomNumberGenerator) -> void:
	var count = get_child_count()
	var choice : int = rand.randi() % count
	
	for i in range(count):
		if i != choice: recursive_disable_slots(get_child(i))


func recursive_disable_slots(node : Node):
	var slot = node as HullPartSlot
	if slot: slot.resolved = true
	for child in node.get_children(): recursive_disable_slots(child)
