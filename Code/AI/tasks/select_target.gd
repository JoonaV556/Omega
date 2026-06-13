@tool
extends BTAction
## SelectTarget [br]
## Selects closest hostile target from an array of node 2ds and exports the chosen target to the output_target_node bb variable [br]
## Utilizes helpful [BBParam] types for getting and setting blackboard variables

## Expects an [Array] of detected [Observable]s or [Node2D]s
@export var input_detected_targets: BBArray

## Expects a [Node2D] of the target 
@export var output_target_node: BBNode

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Select Target"


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
	# get detected targets
	var d_tgts = input_detected_targets.get_value(scene_root, blackboard) as Array[Node2D]
	
	if !d_tgts:
		blackboard.set_var(output_target_node.variable, null)
		return FAILURE

	if d_tgts.is_empty():
		blackboard.set_var(output_target_node.variable, null)
		return FAILURE

	# sort by distance to target from us
	var us = self.agent as Node2D
	d_tgts.sort_custom(
		func closer_to_us(a: Node2D, b: Node2D) -> bool:
			var dist_a = us.global_position.distance_squared_to(a.global_position)
			var dist_b = us.global_position.distance_squared_to(b.global_position)
			if dist_a < dist_b:
				return true
			return false
	)

	# choose first one that's hostile
	var target: Node2D
	var our_fac_node: = agent.get_node("%FactionIdentity") as FactionIdentity

	if !our_fac_node: 
		target = d_tgts[0]
		blackboard.set_var(output_target_node.variable, target.get_parent())
		return SUCCESS # we dont have fac for some reason, just choose closest target
	
	if !our_fac_node.faction:
		target = d_tgts[0]
		blackboard.set_var(output_target_node.variable, target.get_parent())
		return SUCCESS # we dont have fac for some reason, just choose closest target

	for t: Observable in d_tgts:
		var t_fac_node = t.get_parent().get_node("%FactionIdentity") as FactionIdentity
		if !t_fac_node:
			continue
		if !t_fac_node.faction:
			continue
		if FactionRelations.instance.is_hostile(our_fac_node.faction, t_fac_node.faction):
			target = t
			break
	
	if target:
		blackboard.set_var(output_target_node.variable, target.get_parent())
		return SUCCESS

	blackboard.set_var(output_target_node.variable, null)
	return FAILURE


# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
