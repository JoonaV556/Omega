class_name OBTPlayer
extends BTPlayer

@export var node_blackboard: Dictionary[StringName, Node]

@export var var_blackboard: Dictionary[StringName, Variant]


func _enter_tree() -> void:
	set_scene_root_hint(get_tree().current_scene) # try fix scene root errors
