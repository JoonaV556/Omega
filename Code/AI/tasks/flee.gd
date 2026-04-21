@tool
extends BTAdjustableAction
## Flee

## pixels
@export var path_ahead_dist: float = 7.0*16
@export var threat_source_pos := &"pos"
@export var threatened := &"threatened"

## Our own nav agent
var nav_a: NavigationAgent2D

## our npc
var npc: NpcCharacter

var self_node_2d: Node2D

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Flee"


func _adjusted_setup() -> void:
	nav_a = scene_root.get_node("%NavigationAgent2D")
	var _npc := scene_root as NpcCharacter
	npc = _npc


func threat_src_pos() -> Vector2:
	return blackboard.get_var(threat_source_pos, Vector2.ZERO)

func is_threatened() -> bool:
	return blackboard.get_var(threatened, true)

func _adjusted_enter() -> void:
	var level := scene_root.get_tree().current_scene as Level
	var nav_map_rid = level.nav_tilemap.get_navigation_map()
	var s_node2d := scene_root.get_parent() as Node2D
	self_node_2d = s_node2d

	# get first flee point
	var flee_point = ideal_flee_position()
	nav_a.target_position = NavigationServer2D.map_get_closest_point(nav_map_rid, flee_point)


func ideal_flee_position() -> Vector2:
	return self_node_2d.global_position + \
	(Vector2(threat_src_pos() - self_node_2d.global_position).normalized() * -1.0 * path_ahead_dist)


# Called each time this task is exited.
func _exit() -> void:
	npc.move_dir = Vector2.ZERO


# Called each time this task is ticked (aka executed).
func _adjusted_tick(delta: float) -> Status:
	# if no longer threatened, fleeing is succesful
	if !is_threatened():
		return SUCCESS

	# get path to flee point
	var next_path_pos = nav_a.get_next_path_position()

	# move along path
	npc.move_dir = Vector2(next_path_pos - self_node_2d.global_position).normalized()

	# decide next flee point

	return RUNNING

# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
