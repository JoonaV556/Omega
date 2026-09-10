class_name UtilRoadCellGroupGenerator
extends Node2D


@export var tilemap : TileMapLayer


var road_cells : Array[RoadCell]


func _ready() -> void:
    road_cells = []

    for c in get_children():
        if c is UtilRoadCellGenerator:
            var rc = c.generate(tilemap)
            if rc:
                road_cells.append(rc)
    
