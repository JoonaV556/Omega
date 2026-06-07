class_name BTPlayerExtended
extends BTPlayer

@export var node_blackboard: Dictionary[StringName, Node]

func _enter_tree() -> void:
    set_scene_root_hint(get_tree().current_scene) # try fix scene root errors