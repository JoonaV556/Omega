class_name StellarPositionTracker
extends Node

@export var tracked_override: Node2D

@export var start_stellar_position: Vector2i = Vector2i(1000, 1000)

@export var start_local_position: Vector2 = Vector2(50000.0, 50000.0)

signal on_init(chunk_position: Vector2i, local_position: Vector2, world_positon: Vector2)
signal on_chunk_changed(chunk_position: Vector2i, local_position: Vector2, world_positon: Vector2)
signal on_origin_shift_position_treshold_exceeded(_tracked: Node2D)
signal on_origin_shift(current_chunk_coords: Vector2i, local_chunk_position: Vector2, world_position)

var tracked_stellar_pos: Vector2i

## Position of the tracked object inside a chunk local space, in pixels
var tracked_local_chunk_position: Vector2

var _tracked: Node2D
## Position of the tracked inside the actual 2D world
var _tracked_last_real_position: Vector2
var _last_origin_shift_version: int

var _amount_moved_since_last_frame: Vector2

var _exceeded_position_limit_last_frame: bool = false


func _ready() -> void:
	if tracked_override:
		_tracked = tracked_override
	
	if !_tracked:
		var parent = get_parent() as Node2D

		if !parent:
			push_error("No node to track")
			return

		_tracked = parent
	
	if !_tracked:
		push_error("No node to track")
		return
	
	# Set initial position in virtual space coords
	tracked_stellar_pos = start_stellar_position
	tracked_local_chunk_position = start_local_position


	_tracked_last_real_position = _tracked.global_position
	_last_origin_shift_version = SpaceGlobals.origin_shift_version

	_exceeded_position_limit_last_frame = false

	on_init.emit(tracked_stellar_pos, tracked_local_chunk_position, _tracked_last_real_position)


func _physics_process(delta: float) -> void:
	if !_tracked:
		return

	# Check if tracked has moved too far away from world center
	var global_pos := _tracked.global_position
	var treshold := SpaceGlobals.global_position_origin_shift_treshold
	var x_exceeded = global_pos.x > treshold.x or global_pos.x < -treshold.x
	var y_exceeded = global_pos.y > treshold.y or global_pos.y < -treshold.y

	if _exceeded_position_limit_last_frame and (!x_exceeded and !y_exceeded):
		_exceeded_position_limit_last_frame = false ## reset flag

	if x_exceeded or y_exceeded:
		print('Exceeded o-o_shift pos limit treshold')
		on_origin_shift_position_treshold_exceeded.emit(_tracked) # Moved too far away
		_exceeded_position_limit_last_frame = true

	# Check movement delta in real 2d space, taking into account origin shifts
	_amount_moved_since_last_frame = _tracked.global_position - _tracked_last_real_position

	# Account origin shifts
	var o_shift = false
	if _last_origin_shift_version != SpaceGlobals.origin_shift_version:
		_amount_moved_since_last_frame -= SpaceGlobals.origin_shift_amount
		_last_origin_shift_version = SpaceGlobals.origin_shift_version
		o_shift = true
		print('Origin o_shift detected')

	_tracked_last_real_position = _tracked.global_position

	# Update position in virtual chunk space
	var old_chunk := tracked_stellar_pos
	tracked_local_chunk_position += _amount_moved_since_last_frame

	# Update position in stellar chunk space
	var chunk_size_pixels := SpaceGlobals.chunk_size_pixels
	while tracked_local_chunk_position.x >= chunk_size_pixels.x:
		tracked_local_chunk_position.x -= chunk_size_pixels.x
		tracked_stellar_pos.x += 1
	while tracked_local_chunk_position.x < 0.0:
		tracked_local_chunk_position.x += chunk_size_pixels.x
		tracked_stellar_pos.x -= 1
	while tracked_local_chunk_position.y >= chunk_size_pixels.y:
		tracked_local_chunk_position.y -= chunk_size_pixels.y
		tracked_stellar_pos.y += 1
	while tracked_local_chunk_position.y < 0.0:
		tracked_local_chunk_position.y += chunk_size_pixels.y
		tracked_stellar_pos.y -= 1

	# Inform others of origin shift
	if o_shift:
		on_origin_shift.emit(tracked_stellar_pos, tracked_local_chunk_position, _tracked.global_position)

	if tracked_stellar_pos != old_chunk:
		on_chunk_changed.emit(tracked_stellar_pos, tracked_local_chunk_position, _tracked_last_real_position)
		print('Moved to stellar chunk %s (local %s)' % [tracked_stellar_pos, tracked_local_chunk_position])
	
	
