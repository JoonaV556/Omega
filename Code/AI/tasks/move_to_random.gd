@tool
extends BTAction

@export_flags_2d_navigation var navigation_layers = 1

var nav_map_rid
var destination_found: bool = false
var destination: Vector2
var nav_agent: NavigationAgent2D
var npc: NpcCharacter

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "MoveToRandomPoint"

# Called to initialize the task.
func _setup() -> void:
	var level := scene_root as Level
	if not level:
		return
	nav_map_rid = level.nav_tilemap.get_navigation_map()

# Called when the task is entered.
func _enter() -> void:
	pass

# Called when the task is exited.
func _exit() -> void:
	# stop npc movement
	if npc:
		npc.move_dir = Vector2.ZERO
	# reset state for next round
	destination_found = false

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:

	if destination_found and nav_agent.is_target_reached():
		return SUCCESS

	# get random destinations until valid one is found - (this is to skip zero position while nav map is processing)
	if not destination_found:
		var rand_pos: Vector2 = NavigationServer2D.map_get_random_point(
				nav_map_rid, 
				navigation_layers, 
				false
			)

		if not (abs(rand_pos.x) > 0.0):
			return RUNNING

		# valid destination found - set as target
		destination = rand_pos
		var _npc := self.agent as NpcCharacter
		if not _npc:
			push_error("cant find npc root node")
			return FAILURE
		npc = _npc
		nav_agent = npc.nav_agent
		nav_agent.target_position = destination
		destination_found = true
		
		# wait until next physics tick before proceeding with pathfinding and movement
		return RUNNING
	
	# Get next position along path
	var next_path_pos: Vector2 = nav_agent.get_next_path_position()

	# move towards next path pos
	npc.move_dir = Vector2(next_path_pos - npc.global_position)

	return RUNNING


# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
