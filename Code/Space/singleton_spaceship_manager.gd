extends ThrottledNode

## Tracks persistent spaceship instances and updates their behavior trees

## ship, ship_id
var registered_ships: Dictionary[int, SpaceShip]
var ship_ids: Dictionary[SpaceShip, int]

# Ships with AI (behavior trees)
var autonomous_ships: Dictionary[SpaceShip, BTInstance] = {}

##  Interval in seconds between virtualized ship behavior tree updates
const virtualized_ship_bt_update_interval: float = 0.25

static var  _assigned_ids: int = 0


func _throttled_process(delta: float):
	for ship: SpaceShip in autonomous_ships:
		if !ship.is_loaded:
			ship.bt_instance.update(delta)


func _physics_process(delta: float) -> void:
	for ship: SpaceShip in autonomous_ships:
		if ship.is_loaded:
			ship.bt_instance.update(delta)


func register_ship(ship: SpaceShip) -> int:
	var id := _assigned_ids
	registered_ships[id] = ship
	ship_ids[ship] = id

	_assigned_ids += 1

	# Assign behavior tree 
	if ship.bt_resource:
		var inst := SpaceUtils.bt_instantiate(
			ship.bt_resource,
			self,
			self
		)
		
		ship.bt_instance = inst

		# Allow bt tasks to get reference to their spaceship through the blackboard
		inst.get_blackboard().set_var('ship', ship)

		autonomous_ships[ship] = inst

	return id


## Returns id of the ship. Returns -1 if given ship is not registered nor found.
func get_ship_id(ship: SpaceShip) -> int:
	var id = -1

	var found_ship_id := ship_ids.get(ship, -1) as int

	if found_ship_id >= 0:
		id = found_ship_id

	return id


func get_ship(ship_id: int) -> SpaceShip:
	return registered_ships.get(ship_id, null)
	

## TODO - optimize
func get_ships_in_chunk(chunk_coords: Vector2i) -> Array[SpaceShip]:
	var _ships: Array[SpaceShip] = []

	for ship: SpaceShip in registered_ships.values():
		if ship.get_chunk() == chunk_coords:
			_ships.append(ship)

	return _ships
