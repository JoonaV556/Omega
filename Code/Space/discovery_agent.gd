class_name DiscoveryAgent
extends Node

var discovered: Dictionary[Vector2i, bool]


signal on_chunk_discovered(chunk_coords: Vector2i)


func discover(chunk_coords):
	if discovered.has(chunk_coords):
		return

	discovered[chunk_coords] = true

	print('Discovered chunk %s.' % [chunk_coords])
	on_chunk_discovered.emit(chunk_coords)
