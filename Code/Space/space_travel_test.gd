extends Node


@export var player_ship : Node2D

var player_local_pixel_coord


func _ready() -> void:
    var player_char : Character

    player_char.location_stellar_chunk_coordinate = Vector2i(1000, 1000)
    
    player_local_pixel_coord = Vector2(50000.0, 50000.0)
    
    player_ship.global_position = player_local_pixel_coord


func _process(delta: float) -> void:
    var player_new_pos: Vector2 = player_ship.global_position - player_local_pixel_coord 

