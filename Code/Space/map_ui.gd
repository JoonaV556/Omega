class_name MapUI
extends UI

@export var background_root: CanvasLayer

@export var map_nodes_parent: Node2D

@export var map_node_template: Node2D

@export_category("Map chunk settings")
@export var render_chunks_in_radius: int = 2


var chunks_to_render: Dictionary[SpaceChunk, bool]


var _map_chunk_size_pixels: Vector2 = Vector2(100.0, 100.0)

var _origin_chunk_2d_position: Vector2

var _origin_chunk_coords: Vector2i


# Position tracker
var _map_pos_tracker: StellarPositionTracker

var _chunk_loader: ChunkLoader


# Default position
var _default_chunk: Vector2i = Vector2i(1000, 1000)

var _default_local_pos: Vector2 = Vector2(2500, 2500)


var _map_nodes: Dictionary[Vector2i, Sprite2D]


func _ready() -> void:
	_initialize()


func _initialize():
	var center := get_viewport_center_pos()
	_origin_chunk_2d_position = center - (_map_chunk_size_pixels / 2.0)

	# init map position tracker
	_map_pos_tracker = StellarPositionTracker.new()
	add_child(_map_pos_tracker)
	_map_pos_tracker.set_chunk_size_pixels(_map_chunk_size_pixels)
	_map_pos_tracker.on_current_chunk_changed.connect(_update_map_nodes.unbind(1)) # update map nodes when chunk changes
	
	# Move map to default position
	set_map_default_chunk_position(Vector2i(1000, 1000), Vector2(2500, 2500))
	move_to_map_position(_default_chunk, _default_local_pos)

	# Init chunk loader 
	_chunk_loader = ChunkLoader.new()
	_chunk_loader.chunk_loading_radius = Vector2i(render_chunks_in_radius, render_chunks_in_radius)
	_chunk_loader.init(_default_chunk)
	add_child(_chunk_loader)

	print(center)


func set_map_default_chunk_position(chunk: Vector2i, local_pos: Vector2):
	_default_chunk = chunk
	_default_local_pos = local_pos


func move_to_map_position(chunk: Vector2i, local_pos: Vector2):
	_map_pos_tracker.set_position(chunk, local_pos)


func _input(event: InputEvent) -> void:
	if !_active:
		return

	move_map_with_mouse(event)


func move_map_with_mouse(event: InputEvent):
	var m_event := event as InputEventMouseMotion

	if !m_event: 
		return

	var rmb_pressed_down := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)

	if !rmb_pressed_down:
		return
	
	move_map(m_event.relative)


func move_map(move_delta_pixels: Vector2):
	_map_pos_tracker.move(-move_delta_pixels)

	for map_node in map_nodes_parent.get_children():
		if map_node is Node2D:
			map_node.position += move_delta_pixels


func _create_map_nodes():
	_chunk_loader.update_chunks(_map_pos_tracker.current_chunk_coordinates)
	var chunks := _chunk_loader.loaded_chunks

	var created: Array[Vector2i] = []

	for chunk_coords in chunks.keys():
		if !_map_nodes.has(chunk_coords):
			var node := create_map_node(chunk_coords)
			_map_nodes[chunk_coords] = node
			created.append(chunk_coords)

	print('Created %s map nodes:' % [created.size()])
	for coord in created:
		print('\t%s' % [coord])


func _update_map_nodes():
	# Delete nodes outside range
	_delete_nodes_outside_range()

	# Create nodes for new chunks
	_create_map_nodes()


func _delete_nodes_outside_range():
	var chunks := _chunk_loader.loaded_chunks

	var deleted: Array[Vector2i] = []

	for coord in _map_nodes.keys():
		if !chunks.has(coord):
			var node := _map_nodes[coord]
			
			_map_nodes.erase(coord)

			deleted.append(coord)

			if node:
				node.queue_free() 

	print('Deleted %s map nodes:' % [deleted.size()])
	for coord in deleted:
		print('\t%s' % [coord])


func _destroy_map_nodes():
	for c in map_nodes_parent.get_children():
		c.queue_free()


func set_origin_chunk(coords: Vector2i):
	_origin_chunk_coords = coords


func create_map_node(chunk_coords: Vector2i) -> Sprite2D:
	# Get chunk info 
	var params := SpaceChunkGenerator.generator_params.new()
	params.chunk_size_pixels = SpaceGlobals.chunk_size_pixels
	var chunk := SpaceChunkGenerator.generate_chunk(
		chunk_coords,
		SpaceChunkGenerator.ChunkDetailLevel.MEDIUM
	)

	# Create node only for chunks with a system innit
	if chunk.system == null:
		return null

	var node := map_node_template.duplicate()
	map_nodes_parent.add_child(node)

	node.show()

	node.name = String("Map chunk node %s" % [chunk.system.name])

	var system := chunk.system as System
	var primary_object := system.primary_object

	# Calculate and position map node according to its primary object position
	var screen_center := get_viewport_center_pos()
	var current_chunk_pos := screen_center - _map_pos_tracker.current_local_position
	var chunk_offset := Vector2(chunk_coords - _map_pos_tracker.current_chunk_coordinates) * _map_chunk_size_pixels
	var primary_object_offset := (_map_chunk_size_pixels / SpaceGlobals.chunk_size_pixels) * chunk.stellar_objects[primary_object]
	node.position = current_chunk_pos + chunk_offset + primary_object_offset

	return node


func get_viewport_center_pos() -> Vector2:
	return get_viewport().get_visible_rect().size / 2.0
	

func activate():
	super()
	background_root.show()
	_create_map_nodes()


func deactivate():
	super()
	background_root.hide()
	_destroy_map_nodes()
