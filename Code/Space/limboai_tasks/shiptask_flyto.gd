@tool
extends SpaceshipTask
## ShiptaskFlyto_gd


var target_chunk_position: Vector2i

var target_local_position: Vector2

var target_reached_distance_treshold: float = 1.0


var _ship_ctr: SpaceShipController

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Spaceship Task - Fly To"


# Called once during initialization.
func _setup() -> void:
	pass


# Called each time this task is entered.
func _enter() -> void:
	target_chunk_position = blackboard.get_var('target_chunk') as Vector2i
	target_local_position = blackboard.get_var('target_pos') as Vector2


# Called each time this task is exited.
func _exit() -> void:
	pass


func _tick_loaded(_delta: float) -> Status:
	# Get ref to spaceship controller
	if !is_instance_valid(_ship_ctr):
		_ship_ctr = get_ship_controller()

	# todo - End if target reached
	# todo - Fail if target is unreachable

	# Calculate direction to target
	var ship := get_ship()

	var ship_c_pos := ship.get_chunk()
	var ship_loc_pos := ship.get_local_position()

	var steer_towards_direction := SpaceUtils.get_interstellar_direction(
		ship_c_pos,
		ship_loc_pos,
		target_chunk_position,
		target_local_position
	)

	# Move ship
	_ship_ctr.apply_input(
		0.5,
		0.0,
		false,
		SpaceShipController.SteeringMode.STEER_TOWARDS_DIRECTION,
		Vector2.ZERO,
		steer_towards_direction
	)

	return RUNNING


func _tick_virtualized(_delta: float) -> Status:
	return RUNNING


