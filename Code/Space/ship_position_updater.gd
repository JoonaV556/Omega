class_name ShipPositionUpdater
extends Node


var ship_root: SpaceShipController

var last_pos: Vector2


func _ready() -> void:
    ship_root = get_parent() as SpaceShipController
    if ship_root:
        last_pos = ship_root.global_position


func _process(_delta: float) -> void:
    if ship_root:
        var move_delta := ship_root.global_position - last_pos
        last_pos = ship_root.global_position
        
        
