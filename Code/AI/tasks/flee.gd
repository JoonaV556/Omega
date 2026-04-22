@tool
extends BTAdjustableAction
## Flee

## pixels
@export var path_ahead_dist: float = 7.0*16

@export var threat_source_pos_var: 	StringName = &"pos"
@export var is_threatened_var: 		StringName = &"is_threatened"

## Our own nav agent
var nav_a: 			NavigationAgent2D
## our npc
var npc: 			NpcCharacter
var nav_map_rid: RID
var first_flee_set: bool = false

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Flee"


func _adjusted_setup() -> void:
	nav_a = scene_root.get_node("%NavigationAgent2D")
	var _npc := scene_root as NpcCharacter
	npc = _npc


func threat_src_pos() -> Vector2:
	return blackboard.get_var(threat_source_pos_var, Vector2.ZERO)


func is_threatened() -> bool:
	return blackboard.get_var(is_threatened_var, true)


func _adjusted_enter() -> void:
	var level := scene_root.get_tree().current_scene as Level
	nav_map_rid = level.nav_tilemap.get_navigation_map()
	first_flee_set = false


func ideal_flee_position() -> Vector2:
	var away_dir = npc.global_position.direction_to(threat_src_pos()) * -1.0
	return npc.global_position + (away_dir * path_ahead_dist)


# Called each time this task is exited.
func _exit() -> void:
	npc.move_dir = Vector2.ZERO


# Called each time this task is ticked (aka executed).
func _adjusted_tick(delta: float) -> Status:
	# if no longer threatened, fleeing is succesful
	if !is_threatened():
		return SUCCESS

	# wait until navigation map is ready to be queried
	if NavigationServer2D.map_get_iteration_id(nav_map_rid) == 0:
		return RUNNING

	# set first flee point and wait until nav agent paths to it
	if !first_flee_set:
		# get first flee point
		nav_a.target_position = NavigationServer2D.map_get_closest_point(nav_map_rid, ideal_flee_position())
		first_flee_set = true
		return RUNNING

	# get path to flee point
	var next_path_pos = nav_a.get_next_path_position()

	# move along path
	npc.move_dir = npc.global_position.direction_to(next_path_pos)
	# npc.move_dir = -1*npc.global_position.direction_to(threat_src_pos())

	# decide next flee point
	nav_a.target_position = NavigationServer2D.map_get_closest_point(nav_map_rid, ideal_flee_position())

	return RUNNING

# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
