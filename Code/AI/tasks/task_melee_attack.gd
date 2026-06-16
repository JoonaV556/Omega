@tool
extends BTAction
## TaskMeleeAttack

## attack is done in the direction if target_pos
@export var target_pos_var: StringName = &"pos"

## if set, attack is done in the direction of target node instead
@export var target_node: BBNode

var atck: MeleeAttack

var trg_n: Node2D

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Melee Attack"


# Called once during initialization.
func _setup() -> void:
	atck = agent.get_node("%MeleeAttack")


# Called each time this task is entered.
func _enter() -> void:
	trg_n = target_node.get_value(scene_root, blackboard) as Node2D


# Called each time this task is exited.
func _exit() -> void:
	pass


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var trg_pos: Vector2

	if trg_n:
		trg_pos = trg_n.global_position
	else:
		trg_pos = blackboard.get_var(target_pos_var, Vector2.ZERO)

	var attack_result = atck.attack_in_direction(trg_pos)
	return attack_result


# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
