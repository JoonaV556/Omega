@tool
extends BTAction
## Task which succeeds if target pos is within max_distance
class_name BTWithinDistance
## TaskWithinDistance

## @deprecated
@export var target_pos_var: StringName = &"pos"
## pixels
@export var max_distance: float = 16.0

@export var target_node: BBNode

var slf: Node2D

var trg_n: Node2D

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Is within distance?"


# Called once during initialization.
func _setup() -> void:
	pass


# Called each time this task is entered.
func _enter() -> void:
	slf = agent as Node2D
	trg_n = target_node.get_value(scene_root, blackboard) as Node2D

# Called each time this task is exited.
func _exit() -> void:
	pass


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var trg_pos: Vector2

	if trg_n:
		if !trg_n:
			return FAILURE
			
		trg_pos = trg_n.global_position
	else:
		var pos_val = blackboard.get_var(target_pos_var) as Vector2
		if !pos_val:
			return FAILURE
			
		trg_pos = pos_val

	var dist = slf.global_position.distance_to(trg_pos)

	if dist <= max_distance:
		return SUCCESS
	else:
		return FAILURE


# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
