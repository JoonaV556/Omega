@tool
extends SpaceshipTask
## ShiptaskFlyto_gd

var _ship_ctr: SpaceShipController

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Spaceship Task - Fly To"


# Called once during initialization.
func _setup() -> void:
	pass


# Called each time this task is entered.
func _enter() -> void:
	pass


# Called each time this task is exited.
func _exit() -> void:
	pass


func _tick_loaded(delta: float) -> Status:
	# Get ref to spaceship controller
	if !is_instance_valid(_ship_ctr):
		_ship_ctr = get_ship_controller()

	
	
	return RUNNING


func _tick_virtualized(delta: float) -> Status:
	return RUNNING


