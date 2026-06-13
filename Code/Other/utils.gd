class_name Utils
extends Object

# Returns the first child that matches the given type, or null
static func get_child_by_type(nd: Node, type: Variant) -> Node:
	for child in nd.get_children():
		if is_instance_of(child, type):
			return child
	return null

static func sort_distance_to_us(us: Node2D, them: Array[Node2D]) -> Array[Node2D]:
	var ret = them.duplicate()
	ret.sort_custom(
		func closer_to_us(a: Node2D, b: Node2D) -> bool:
			var dist_a = us.global_position.distance_squared_to(a.global_position)
			var dist_b = us.global_position.distance_squared_to(b.global_position)
			if dist_a < dist_b:
				return true
			return false
	)
	return ret
