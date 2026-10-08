class_name MapUI
extends UI

@export var background_root: CanvasLayer

@export var map_nodes_parent: Node2D

@export var map_node_template: Node2D


var chunks_to_render: Dictionary[SpaceChunk, bool]


var _map_chunk_size_pixels: Vector2 = Vector2(100.0, 100.0)

var _origin_chunk_2d_position: Vector2

var _origin_chunk_coords: Vector2i


func _ready() -> void:
	var visible_size := get_viewport().get_visible_rect().size
	var center := visible_size / 2.0
	_origin_chunk_2d_position = center - (_map_chunk_size_pixels / 2.0)

	print(center)


func _input(event: InputEvent) -> void:
	var m_event := event as InputEventMouseMotion

	if !m_event: 
		return
	
	move_map(m_event.relative)


func move_map(move_delta_pixels: Vector2):
	pass


func _create_map_nodes():
	for chunk in chunks_to_render.keys():
		create_map_node(chunk)


func _destroy_map_nodes():
	for c in map_nodes_parent.get_children():
		c.queue_free()


func set_origin_chunk(coords: Vector2i):
	_origin_chunk_coords = coords


func create_map_node(chunk: SpaceChunk):
	if !chunks_to_render.has(chunk):
		chunks_to_render[chunk] = true

	if !_active:
		return

	if chunk.stellar_type is not System:
		return

	var map_node  := map_node_template.duplicate() as Sprite2D

	map_nodes_parent.add_child(map_node)

	map_node.show()
	map_node.z_as_relative = false
	map_node.name = String('map node %s' % [chunk.stellar_type.name])

	# Calculate where the map node is placed
	var chunk_2d_offset := Vector2(chunk.coordinates - _origin_chunk_coords) * _map_chunk_size_pixels
	var system := chunk.stellar_type as System
	var master_local_pos := chunk.stellar_objects[system.master_object]
	var chunk_master_offset := master_local_pos * (_map_chunk_size_pixels / SpaceGlobals.chunk_size_pixels)

	map_node.position = _origin_chunk_2d_position + chunk_2d_offset + chunk_master_offset
	map_node.centered = true


func activate():
	super()
	background_root.show()
	_create_map_nodes()


func deactivate():
	super()
	background_root.hide()
	_destroy_map_nodes()
