class_name CurrentLocationLabel
extends Label


func set_location(coords: Vector2i):
	var chunk := SpaceChunkGenerator.generate_chunk(coords, SpaceChunkGenerator.ChunkDetailLevel.LOW)
	var system := chunk.system as System

	var gal_loc_str

	if chunk.galaxy:
		gal_loc_str = "Galaxy: %s" % [chunk.galaxy.name]
	else:
		gal_loc_str = "Deep Space."

	var _sys_loc_str

	if system:
		_sys_loc_str = String("system %s." % [system.name])
	else:
		_sys_loc_str = "empty pocket."

	var full := String("%s\nFlying in %s\nCoordinates: %s." % [gal_loc_str,_sys_loc_str, coords])

	text = full
