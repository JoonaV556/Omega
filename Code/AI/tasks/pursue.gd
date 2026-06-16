@tool
extends BTAction
class_name TPursue
## Pursue
## continuously moves npc towards a specific position or a target Node2D

@export var target_position_var: BBVector2
## pixels
@export var close_enough_distance: float = 16.0

@export_group("Optional - Pursue Node")
@export var pursue_node: bool = false
@export var target_node_var: BBNode

var npc: 	NpcCharacter
var nav_a: 	NavigationAgent2D

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Pursue"

# Called once during initialization.
func _setup() -> void:
	pass

# Called each time this task is entered.
func _enter() -> void:
	# get npc mover
	var _npc := self.agent as NpcCharacter
	if not _npc:
		push_error("cant find npc root node")
	npc = _npc
	
	# get nav agent
	nav_a = npc.nav_agent

	# set target pos 
	nav_a.set_target_position(_get_target_pos())

# Called each time this task is exited.
func _exit() -> void:
	# stop npc movement
	if npc:
		npc.move_dir = Vector2.ZERO

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	return update(delta)

func update(delta: float) -> Status:
	if !npc:
		return FAILURE

	# get target position
	var target_pos: Vector2 = _get_target_pos()

	# stop moving if close enough
	# request new path if not yet close enough
	var close_enough = npc.global_position.distance_to(target_pos) <= close_enough_distance
	if nav_a.is_navigation_finished():
		if close_enough:
			npc.move_dir = Vector2.ZERO
		else:
			nav_a.set_target_position(_get_target_pos())
		return RUNNING

	# get next pos on path
	var next_pos = nav_a.get_next_path_position()

	# move towards target
	npc.move_dir = Vector2(next_pos - npc.global_position)

	return RUNNING

# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings

func _get_target_pos() -> Vector2:
	if !pursue_node:
		var p_ret = target_position_var.get_value(scene_root, blackboard)
		if !p_ret:
			push_error("error retrieving pursue target position value from blackboard")
		return p_ret

	var ret = target_node_var.get_value(scene_root, blackboard) as Node2D
	
	if !ret:
		push_error("error retrieving pursue target node reference from blackboard")
		return Vector2.ZERO

	return ret.global_position
