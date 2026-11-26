class_name SpaceShip
extends RefCounted


var name: String

var position_tracker: VirtualStellarPositionTracker

var is_loaded: bool = false

## Meters per second
var max_speed: float = 50.0

## AI 
var bt_resource: BehaviorTree

var bt_instance: BTInstance



func _init() -> void:
    position_tracker = VirtualStellarPositionTracker.new()


func get_chunk() -> Vector2i:
    return position_tracker.current_chunk_coordinates


func get_local_position() -> Vector2:
    return position_tracker.current_local_position


func get_max_speed_pixels() -> float:
    return max_speed * 16.0


func get_max_speed_mps() -> float:
    return max_speed