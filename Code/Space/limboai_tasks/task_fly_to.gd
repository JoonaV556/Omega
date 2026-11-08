@tool
extends BTAction
## TaskFlyTo


@export var target_position_nodepath: NodePath

var target_found: bool = false

var target_position: Vector2

var ss_controller: SpaceShipController

var nav_agent: NavigationAgent2D

var next_path_pos: Vector2


# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "SpaceTask - Fly To Position"


# Called once during initialization.
func _setup() -> void:
	pass


# Called each time this task is entered.
func _enter() -> void:
	var scene_root_2d := scene_root as Node2D
	var pos_node := scene_root.get_node(target_position_nodepath) as Node2D
	
	if pos_node and scene_root_2d:
		target_position = pos_node.global_position
		target_found = true

		ss_controller = agent as SpaceShipController

		nav_agent = agent.get_node("%NavigationAgent2D")

		nav_agent.target_position = target_position

		await agent.get_tree().physics_frame

		next_path_pos = nav_agent.get_next_path_position()


# Called each time this task is exited.
func _exit() -> void:
	target_found = false


# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	if !target_found:
		return FAILURE

	var navigation_map := nav_agent.get_navigation_map()
	var has_navigation_regions := navigation_map.is_valid() and not NavigationServer2D.map_get_regions(navigation_map).is_empty()

	if has_navigation_regions and nav_agent.is_navigation_finished():
		if ss_controller:
			_hold_heading()
		return SUCCESS

	if has_navigation_regions:
		next_path_pos = nav_agent.get_next_path_position()
	else:
		if ss_controller and ss_controller.global_position.distance_to(target_position) <= maxf(nav_agent.target_desired_distance, 1.0):
			_hold_heading()
			return SUCCESS
		next_path_pos = target_position

	if ss_controller:
		_apply_navigation_input()

	return RUNNING


func _apply_navigation_input() -> void:
	var displacement := next_path_pos - ss_controller.global_position
	var distance := displacement.length()
	var mass := maxf(ss_controller.mass, 0.001)
	var travel_direction := displacement.normalized()
	var forward := Vector2.UP.rotated(ss_controller.global_rotation)
	var right := Vector2.RIGHT.rotated(ss_controller.global_rotation)
	# Estimate braking force along the path using the thruster limits in that direction.
	var reverse_direction := -travel_direction
	var forward_brake_projection := reverse_direction.dot(forward)
	var strafe_brake_projection := reverse_direction.dot(right)
	var forward_brake_force := ss_controller.forward_thruster_force if forward_brake_projection >= 0.0 else ss_controller.backward_thruster_force
	var braking_acceleration := (
		absf(forward_brake_projection) * forward_brake_force
		+ absf(strafe_brake_projection) * ss_controller.strafing_thruster_force
	) / mass
	var response_time := 0.5
	var approach_speed := maxf(ss_controller.linear_velocity.dot(travel_direction), 0.0)
	var distance_after_response := maxf(distance - approach_speed * response_time, 0.0)
	var target_speed := minf(
		ss_controller.max_speed * 16.0,
		sqrt(2.0 * braking_acceleration * distance_after_response)
	)
	var desired_velocity := travel_direction * target_speed
	# Correct current velocity toward the path point over a short response interval.
	var desired_acceleration := (desired_velocity - ss_controller.linear_velocity) / response_time
	# Convert the world-space correction into forward/backward and lateral inputs.
	var forward_acceleration := desired_acceleration.dot(forward)
	var strafe_acceleration := desired_acceleration.dot(right)
	var forward_force := ss_controller.forward_thruster_force if forward_acceleration >= 0.0 else ss_controller.backward_thruster_force
	var thrust := forward_acceleration * mass / forward_force if forward_force > 0.0 else 0.0
	var strafe := strafe_acceleration * mass / ss_controller.strafing_thruster_force if ss_controller.strafing_thruster_force > 0.0 else 0.0

	ss_controller.apply_input(next_path_pos, thrust, strafe)


func _hold_heading() -> void:
	var aim_direction := ss_controller.linear_velocity.normalized()
	if aim_direction.is_zero_approx():
		aim_direction = Vector2.UP.rotated(ss_controller.global_rotation)
	ss_controller.apply_input(ss_controller.global_position + aim_direction * 1000.0, 0.0, 0.0)


# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
