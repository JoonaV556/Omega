@tool
extends BTAdjustableAction
## Flee

## pixels
@export var path_ahead_dist: float = 14.0*16
## degrees
@export var threat_angle_recalculate_treshold: float = 45.0

@export var threat_source_pos_var: 	StringName = &"pos"
@export var is_threatened_var: 		StringName = &"is_threatened"
@export_flags_2d_navigation var nav_blocking_layers = (1 << 1 - 1) # tick layer 1 by default. see @https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html#collision-layers-and-masks
@export var reverse_from_dead_end_distance: float = 5.0

# The following ticks layers 1, 3 and 4
# (1 << 1 - 1) | (1 << 3 - 1) | (1 << 4 - 1)

## Our own nav agent
var nav_a: 			NavigationAgent2D
## our npc
var npc: 			NpcCharacter
var nav_map_rid: RID
var first_flee_set: bool = false

var space_state: PhysicsDirectSpaceState2D
var ray_query: PhysicsRayQueryParameters2D
var last_flee_vector: Vector2

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Flee"


func _adjusted_setup() -> void:
	nav_a = scene_root.get_node("%NavigationAgent2D")
	var _npc := scene_root as NpcCharacter
	npc = _npc
	space_state = scene_root.get_world_2d().direct_space_state

	# init ray query
	ray_query = PhysicsRayQueryParameters2D.create(
		npc.global_position, 
		npc.global_position, 
		nav_blocking_layers
		)
	var exclude = ray_query.exclude
	exclude = [npc.get_rid()]
	ray_query.exclude = exclude

func threat_src_pos() -> Vector2:
	return blackboard.get_var(threat_source_pos_var, Vector2.ZERO)


func is_threatened() -> bool:
	return blackboard.get_var(is_threatened_var, true)


func _adjusted_enter() -> void:
	var level := scene_root.get_tree().current_scene as Level
	nav_map_rid = level.nav_tilemap.get_navigation_map()
	first_flee_set = false

	# start sprinting
	npc.set_sprinting(true)


func ideal_flee_position() -> Vector2:
	var away_dir = get_away_direction()
	return npc.global_position + (away_dir.normalized() * path_ahead_dist)

func get_away_direction() -> Vector2:
	return npc.global_position.direction_to(threat_src_pos()) * -1.0

# Called each time this task is exited.
func _exit() -> void:
	npc.move_dir = Vector2.ZERO

	# stop sprinting once in safety
	npc.set_sprinting(false)


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
		last_flee_vector = get_away_direction()
		nav_a.target_position = NavigationServer2D.map_get_closest_point(nav_map_rid, ideal_flee_position())
		first_flee_set = true
		return RUNNING

	# get path to flee point
	var next_path_pos = nav_a.get_next_path_position()

	# move along path
	var moving_to = npc.global_position.direction_to(next_path_pos)
	npc.move_dir = moving_to

	# decide whether or not we should decide a new flee position
	var should_recalculate = false
	var threat_angle_delta = rad_to_deg(last_flee_vector.angle_to(get_away_direction()))
	should_recalculate = nav_a.is_target_reached() or (threat_angle_delta >= threat_angle_recalculate_treshold)

	if should_recalculate:
		last_flee_vector = get_away_direction()
		var target = ideal_flee_position()
		nav_a.target_position = NavigationServer2D.map_get_closest_point(nav_map_rid, target)

	return RUNNING

# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
