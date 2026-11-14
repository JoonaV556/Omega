class_name SpaceShip
extends RefCounted


var position_tracker: VirtualStellarPositionTracker


func _init() -> void:
    position_tracker = VirtualStellarPositionTracker.new()

    SpaceshipManager.register_ship(self)


func get_chunk() -> Vector2i:
    return position_tracker.current_chunk_coordinates


func get_local_position() -> Vector2:
    return position_tracker.current_local_position