@abstract class_name SpaceshipTask
extends BTAction
## SpaceshipTask


# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "SpaceshipTask"


func _setup() -> void:
	pass


func _enter() -> void:
	pass


func _exit() -> void:
	pass


## IF OVERRIDDEN, CALL SUPER_tick first !!!
func _tick(delta: float) -> Status:
	# Check whether or not the ship is loaded
	var ship := get_ship()

	if ship.is_loaded:
		return _tick_loaded(delta)
	else:
		return _tick_virtualized(delta)
	

@abstract
func _tick_virtualized(delta: float) -> Status


@abstract
func _tick_loaded(delta: float) -> Status


# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings


## Returns the associated spaceship instance this task & behavior tree belongs to
func get_ship() -> SpaceShip:
	var ship := blackboard.get_var('ship') as SpaceShip

	if !ship:
		push_error("Spaceship task couldn't get reference to spaceship instance!")
		
	return ship