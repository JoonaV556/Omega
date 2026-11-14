extends Node

func _ready() -> void:
    
    var ship := SpaceShip.new()
    ship.position_tracker.set_position(
        Vector2i(998, 1000), 
        Vector2(SpaceGlobals.chunk_size_pixels / 2.0)
        )