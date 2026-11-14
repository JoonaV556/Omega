extends Node


var ships: Dictionary[SpaceShip, int]


func register_ship(ship: SpaceShip):
	ships[ship] = ship.get_instance_id()


## TODO - optimize
func get_ships_in_chunk(chunk_coords: Vector2i) -> Array[SpaceShip]:
	var _ships: Array[SpaceShip] = []

	for ship: SpaceShip in ships.keys():
		if ship.get_chunk() == chunk_coords:
			_ships.append(ship)

	return _ships
