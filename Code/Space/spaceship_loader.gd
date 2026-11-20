## Loads / Instantiates ship nodes in currently loaded chunks
class_name ShipLoader
extends ThrottledNode

@export var spaceship_scene: PackedScene

@export var ship_nodes_parent: Node:
	set(value):
		if !value:
			ship_nodes_parent = self
		else:
			ship_nodes_parent = value


var _loaded_chunks: Array[Vector2i] = []

var _loaded_ships: Dictionary[SpaceShip, bool] = {}


func _throttled_process(delta: float):

	# Load unloaded ships in loaded area
	var ships: Array[SpaceShip] # get ships in loaded chunks
	for chunk in _loaded_chunks:
		ships.append_array(SpaceshipManager.get_ships_in_chunk(chunk))

	for ship: SpaceShip in ships:
		
		if !spaceship_scene:
			continue

		var ship_id = SpaceshipManager.get_ship_id(ship)
		var ship_ctr := spaceship_scene.instantiate() as SpaceShipController

		ship_ctr.ship_id = ship_id

		# Place ship in correct position
		var ship_world_pos: Vector2

		_loaded_ships[ship] = true


	# Unload loaded ships outside loaded area
	
	
	pass


func update_loaded_chunks(loaded_chunks: Array[Vector2i]):
	_loaded_chunks = loaded_chunks
