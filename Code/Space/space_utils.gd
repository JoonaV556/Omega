class_name SpaceUtils
extends RefCounted


static func get_object_type_string(object: SpaceObject) -> String:

	if object is System:
		return "System"

	if object is Planet:
		return "Planet"

	return "Unknown"


static func get_galaxy_space_coords(chunk_coords) -> Vector2i:
	return Vector2i(
		floori(float(chunk_coords.x) / SpaceGlobals.galaxy_cell_size.x),
		floori(float(chunk_coords.y) / SpaceGlobals.galaxy_cell_size.y)
	)


static func wait_process_ticks(node: Node, ticks: int) -> void:
	for i in range(max(ticks, 0)):
		await node.get_tree().process_frame