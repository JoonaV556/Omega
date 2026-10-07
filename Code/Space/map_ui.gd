class_name MapUI
extends UI

@export var background_root: CanvasLayer


var chunks_to_render: Dictionary[Vector2i, bool]


var _map_chunk_size_pixels: Vector2 = Vector2(200.0, 200.0)

var _origin_chunk_2d_position: Vector2


func _ready() -> void:
	var visible_size := get_viewport().get_visible_rect().size
	var center := visible_size / 2.0
	_origin_chunk_2d_position = center - (_map_chunk_size_pixels / 2.0)

	print(center)


func _render_all_chunks():
	for chunk_coord: Vector2i in chunks_to_render.keys():
		render_chunk(chunk_coord)


func render_chunk(chunk_coords: Vector2i):
	if !chunks_to_render.has(chunk_coords):
		chunks_to_render[chunk_coords] = true

	if !_active:
		return


func activate():
	super()
	background_root.show()


func deactivate():
	super()
	background_root.hide()
