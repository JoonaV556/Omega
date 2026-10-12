class_name CurrentLocationLabel
extends Label


func set_location(coords: Vector2i):
	var chunk := SpaceChunkGenerator.generate_chunk(coords, SpaceChunkGenerator.ChunkDetailLevel.LOW)
	var system := chunk.system as System

	var _loc_str

	if system:
		_loc_str = String("system %s." % [system.name])
	else:
		_loc_str = "empty space."

	var full := String("Flying in %s\nCoordinates: %s." % [_loc_str, coords])

	text = full
