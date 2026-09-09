@tool
class_name UtilRoadCellGenerator
extends Node2D

## Size in tilemap tiles (16x16px)
@export var size : Vector2i = Vector2i(4, 4):
    set(value):
        size = value
        queue_redraw()

@export var preview_outline_color : Color = Color.WHITE
@export var preview_outline_thickness : float = 1.5

@export_category("Connections")
@export var connection_north : bool = false
@export var connection_south : bool = false
@export var connection_east : bool = false
@export var connection_west : bool = false

var cell : RoadCell

const TILE_SIZE_PIXELS : int = 16


func _draw() -> void:
    if size == Vector2i.ZERO:
        return

    var pixels := Vector2(size.x, size.y) * TILE_SIZE_PIXELS
    draw_rect(
        Rect2(Vector2.ZERO, pixels),
        preview_outline_color,
        false,
        preview_outline_thickness
    )


func _ready() -> void:
    var _c = RoadCell.new()
    _c.size = size

    # Define connections
    var connections = 0
    if connection_north:
        connections = LevelGenerator.add_connection(
            connections, 
            LevelGenerator.R_CONNECTION_N
            )
    if connection_south:
        connections = LevelGenerator.add_connection(
            connections, 
            LevelGenerator.R_CONNECTION_S
            )
    if connection_east:
        connections = LevelGenerator.add_connection(
            connections, 
            LevelGenerator.R_CONNECTION_E
            )
    if connection_west:
        connections = LevelGenerator.add_connection(
            connections, 
            LevelGenerator.R_CONNECTION_W
            )

    # Define tilemap pattern
    var tmap = get_parent() as TileMapLayer
    if !tmap: 
        push_error("No Tilemaplayer found, cannot generate pattern")
        return 
    var origin_cell = Vector2i(int(position.x) / 16, int(position.y) / 16)
    _c.tilemap_pattern = OmegaUtils.get_pattern_from_cell(
        tmap,
        origin_cell,
        size
    )

    # Define plots 
    #TODO
 
    cell = _c