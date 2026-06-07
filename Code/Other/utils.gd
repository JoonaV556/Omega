class_name Utils
extends Object

# Returns the first child that matches the given type, or null
static func get_child_by_type(nd: Node, type: Variant) -> Node:
	for child in nd.get_children():
		if is_instance_of(child, type):
			return child
	return null
