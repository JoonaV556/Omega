@tool
extends BTAction
## Pursue
## continuously moves npc towards a specific position 

@export var target_position_var := &"pos"
## pixels
@export var close_enough_distance: float = 16.0

var npc: 	NpcCharacter
var nav_a: 	NavigationAgent2D

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Pursue - Endless"

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
	var target_pos: Vector2 = blackboard.get_var(target_position_var, Vector2.ZERO, true)
	nav_a.target_position = target_pos

# Called each time this task is exited.
func _exit() -> void:
	# stop npc movement
	if npc:
		npc.move_dir = Vector2.ZERO

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if !npc:
		return FAILURE

	var target_pos: Vector2 = blackboard.get_var(target_position_var, Vector2.ZERO, true)

	# set target pos
	nav_a.target_position = target_pos

	if target_pos == Vector2(0.0, 0.0):
		print("catch")

	# get paths
	var next_pos = nav_a.get_next_path_position()
	
	if (npc.global_position.distance_to(target_pos)) <= close_enough_distance:
		npc.move_dir = Vector2.ZERO
	else:
		# move npc
		npc.move_dir = Vector2(next_pos - npc.global_position)
	
	return RUNNING


# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
