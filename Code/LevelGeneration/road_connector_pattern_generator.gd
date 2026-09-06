## Specialized pattern generator for road connector cells (crossroads), which organizes patterns based on road connections order
class_name RoadConnectorPatternGenerator
extends TileMapPatternGenerator

## Highways, small roads
const road_connections_order : Array[Array] = [
    [4+8, 1],
    [1+2, 8],
    [1+8, 2],
    [8+2, 4],
    [2+4, 8],
    [1+4, 2],
    [4+8, 2],
    [1+2, 4],
    [1+8, 4],
    [8+2, 1],
    [2+4, 1],
    [1+4, 8],
    [4+8, 1+2],
    [1+2, 4+8],
    [1+8, 2+4],
    [8+2, 1+4],
    [2+4, 1+8],
    [1+4, 2+8],
    [1+4+8, 2],
    [1+8+2, 4],
    [2+4+8, 1],
    [1+2+4, 8],
]

var connector_patterns : Dictionary[Array, TileMapPattern]


func _ready() -> void:
    _generate_patterns()

    # organize based on road connections
    for n in range(road_connections_order.size()):
        var _connections = road_connections_order[n]
        connector_patterns[_connections] = patterns[n]


func get_connector_pattern(highway_connections : int, small_road_connections : int) -> TileMapPattern:
    return connector_patterns[[highway_connections, small_road_connections]]