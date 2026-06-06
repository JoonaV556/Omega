extends Node


@export var bb_var: StringName
@export var target_nd: Node
@export var target_val: StringName
var first = true
func _enter_tree() -> void:
	if first:
		first = false
		return
		
	var bb = get_parent() as BTPlayer
	bb.blackboard.bind_var_to_property(bb_var, target_nd, target_val)
