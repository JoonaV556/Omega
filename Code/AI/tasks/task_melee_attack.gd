@tool
extends BTAction
## TaskMeleeAttack

@export var target_pos_var: StringName = &"pos"

var atck: MeleeAttack

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "TaskMeleeAttack"


# Called once during initialization.
func _setup() -> void:
	atck = agent.get_node("%MeleeAttack")


# Called each time this task is entered.
func _enter() -> void:
	pass


# Called each time this task is exited.
func _exit() -> void:
	pass


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var trg_pos: Vector2 = blackboard.get_var(target_pos_var, Vector2.ZERO)
	var attack_result = atck.attack_in_direction(trg_pos)
	return attack_result


# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
