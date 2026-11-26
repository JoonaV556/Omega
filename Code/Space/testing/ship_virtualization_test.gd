extends Node

func _ready() -> void:
	
	var ship := SpaceShip.new()
	ship.position_tracker.set_position(
		Vector2i(998, 1000), 
		Vector2(SpaceGlobals.chunk_size_pixels / 2.0)
		)

	SpaceshipManager.register_ship(ship)


	# Test virtualized behavior trees on ships
	var bt_res: BehaviorTree = load("res://Code/Space/limboai_behavior_trees/bt_waypoint_test.tres")
	var ship_b := SpaceShip.new()
	ship_b.bt_resource = bt_res
	ship_b.name = "wp test"

	# Set initial position
	ship_b.position_tracker.set_position(Vector2i(997, 1000), Vector2(SpaceGlobals.chunk_size_pixels / 2.0))

	# Register
	SpaceshipManager.register_ship(ship_b)
