class_name TilemapLayerExtensions
extends Node

## fills square area in tilemap with specific tile
static func fill_area(tmap : TileMapLayer, _origin: Vector2i, _size: Vector2i, _tile_source_id: int, _tile_atlascoords: Vector2i):
	for _y in range(_origin.y, (_origin.y + _size.y)):
		for _x in range(_origin.x, (_origin.x + _size.x)):
			tmap.set_cell(Vector2i(_x, _y), _tile_source_id, _tile_atlascoords)