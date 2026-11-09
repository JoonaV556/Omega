@tool
extends BTAction
## TaskFlyTo


@export var target_position_nodepath: NodePath

const VELOCITY_RESPONSE_TIME := 0.5

var target_found: bool = false

var target_position: Vector2

var ss_controller: SpaceShipController

var nav_agent: NavigationAgent2D

var next_path_pos: Vector2

var previous_avoidance_enabled: bool

var previous_agent_max_speed: float


# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "SpaceTask - Fly To Position"

# Called each time this task is entered.
func _enter() -> void:
	var scene_root_2d := scene_root as Node2D
	var pos_node := scene_root.get_node(target_position_nodepath) as Node2D
	
	if pos_node and scene_root_2d:
		target_position = pos_node.global_position
		target_found = true

		ss_controller = agent as SpaceShipController

		nav_agent = agent.get_node("%NavigationAgent2D")

		# Enable avoidance
		previous_avoidance_enabled = nav_agent.avoidance_enabled
		previous_agent_max_speed = nav_agent.max_speed
		if ss_controller:
			nav_agent.max_speed = ss_controller.max_speed * 16.0
		nav_agent.avoidance_enabled = true
		if not nav_agent.velocity_computed.is_connected(_on_navigation_velocity_computed):
			nav_agent.velocity_computed.connect(_on_navigation_velocity_computed)

		nav_agent.target_position = target_position

		await agent.get_tree().physics_frame


# Called each time this task is exited.
func _exit() -> void:
	if nav_agent:
		if nav_agent.velocity_computed.is_connected(_on_navigation_velocity_computed):
			nav_agent.velocity_computed.disconnect(_on_navigation_velocity_computed)
		nav_agent.velocity = Vector2.ZERO
		nav_agent.avoidance_enabled = previous_avoidance_enabled
		nav_agent.max_speed = previous_agent_max_speed
	target_found = false


# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	if not target_found or not ss_controller or not nav_agent:
		return FAILURE

	if nav_agent.is_navigation_finished():
			_stop_movement()
			return SUCCESS

	if not _has_navigation_regions():
		_stop_movement()
		return RUNNING

	next_path_pos = nav_agent.get_next_path_position()
	_apply_navigation_input()

	return RUNNING


func _has_navigation_regions() -> bool:
	var navigation_map := nav_agent.get_navigation_map()
	return navigation_map.is_valid() and not NavigationServer2D.map_get_regions(navigation_map).is_empty()


func _has_valid_path() -> bool:
	return nav_agent.is_target_reachable() and not nav_agent.get_current_navigation_path().is_empty()


func _stop_movement() -> void:
	nav_agent.velocity = Vector2.ZERO
	_hold_heading()


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
	var approach_speed := maxf(ss_controller.linear_velocity.dot(travel_direction), 0.0)
	var distance_after_response := maxf(distance - approach_speed * VELOCITY_RESPONSE_TIME, 0.0)
	var target_speed := minf(
		ss_controller.max_speed * 16.0,
		sqrt(2.0 * braking_acceleration * distance_after_response)
	)
	var desired_velocity := travel_direction * target_speed
	nav_agent.velocity = desired_velocity


func _on_navigation_velocity_computed(safe_velocity: Vector2) -> void:
	if not target_found or not ss_controller or not nav_agent:
		return
	if not _has_navigation_regions():
		return

	var mass := ss_controller.mass
	var forward_vec := Vector2.UP.rotated(ss_controller.global_rotation)
	var right_vec := Vector2.RIGHT.rotated(ss_controller.global_rotation)
	
	# Convert the avoidance-adjusted velocity into forward/backward and lateral inputs.
	var desired_acceleration := (safe_velocity - ss_controller.linear_velocity) / VELOCITY_RESPONSE_TIME
	var forward_acceleration := desired_acceleration.dot(forward_vec)
	var strafe_acceleration := desired_acceleration.dot(right_vec)
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
