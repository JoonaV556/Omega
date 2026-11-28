@abstract class_name SpaceshipTask
extends BTAction
## SpaceshipTask


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


## Returns the associated spaceship instance this task & behavior tree belongs to
func get_ship() -> SpaceShip:
	var ship := blackboard.get_var('ship') as SpaceShip

	if !ship:
		push_error("Spaceship task couldn't get reference to spaceship instance!")
		
	return ship


## Works only when the ship is loaded and its node is present
func get_ship_controller() -> SpaceShipController:
	return SpaceChunkRenderer.instance.get_ship_controller(get_ship())