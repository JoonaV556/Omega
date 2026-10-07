class_name DiscoveryAgent
extends Node

var discovered_chunk_coords: Dictionary[Vector2i, bool]


signal on_chunk_discovered(chunk: SpaceChunk)


func discover(chunk: SpaceChunk):
	if discovered_chunk_coords.has(chunk.coordinates):
		return

	discovered_chunk_coords[chunk.coordinates] = true

	print('Discovered chunk %s.' % [chunk.coordinates])
	on_chunk_discovered.emit(chunk)
