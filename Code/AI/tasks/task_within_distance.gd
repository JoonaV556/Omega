@tool
extends BTAction
## Task which succeeds if target pos is within max_distance
class_name BTWithinDistance
## TaskWithinDistance

@export var target_pos_var: StringName = &"pos"
## pixels
@export var max_distance: float = 16.0

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "TaskWithinDistance"


# Called once during initialization.
func _setup() -> void:
	pass


# Called each time this task is entered.
func _enter() -> void:
	pass


# Called each time this task is exited.
func _exit() -> void:
	pass


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var slf := agent as Node2D
	var trg_pos: Vector2 = blackboard.get_var(target_pos_var, Vector2.ZERO)
	var dist = slf.global_position.distance_to(trg_pos)
	if dist <= max_distance:
		return SUCCESS
	else:
		return FAILURE


# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
