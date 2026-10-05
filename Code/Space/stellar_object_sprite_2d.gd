class_name StellarObjectSprite2D
extends Sprite2D

var _cached_texture: Texture

var radius_pixels: float


func set_radius_pixels(value: float) -> void:
	radius_pixels = value

	_cached_texture = texture

	texture = null

	queue_redraw()


func _draw() -> void:
	if _cached_texture == null:
		return

	var diameter := radius_pixels * 2.0
	draw_texture_rect(_cached_texture, Rect2(-radius_pixels, -radius_pixels, diameter, diameter), false)