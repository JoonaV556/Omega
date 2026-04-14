## Cursor reticle suitable for weapons / aiming.
class_name AimCursor
extends Node

@export var cursor_sprite_options: Array[Texture2D]

@export_range(0.01, 100.0) var cursor_scale: float = 1.0

@export var cursor_color: Color = Color.WHITE

@export var cursor_texture_index:int = 0

@export var player: Node2D

## pixels
@export var cursor_max_distance_from_player: float = 40*16 # 40 world tiles

@export_range(0.01, 9999.0) var cursor_sensitivity_multiplier: float = 1.0

## if set, cursor Sprite2D node is parented to this node instead of the script node itself
@export var cursor_custom_parent: Node

## optional
@export var cursor_material: Material

## Optional. If provided, the the helper nodes position is set to follow the actual world position of the aim cursor. Useful for pivoting stuff where the cursor is in "world"
@export var cursor_world_pos_helper: Node2D
## Optional. Useful for making a camera follow the aiming cursor 
@export var cursor_camera_follow_helper: Node2D

@export var camera_helper_placement_mode: CamHelperMode = CamHelperMode.FOLLOW_CURSOR

## 0.0 is follow player. 0.5 true middle point. 1.0 is cursor. 
@export_range(0.0, 1.0) var middle_point_alpha: float = 0.5

enum CamHelperMode {FOLLOW_CURSOR, FOLLOW_MIDDLE_POINT}

const scale_min: float = 0.01
const scale_max: float = 100.0
const scale_step: float = 0.1

## start offset relative to player
const cursor_start_world_offset: Vector2 = Vector2(0.0, 0.0)
## cursor position relative to player
var cursor_world_offset: Vector2 = Vector2(0, 0)
var cursor_world_pos: Vector2

var aim_cursor_sprite: Sprite2D

var camera_ref: Camera2D

func _ready() -> void:
	# hide system cursor
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# create aim cursor 
	aim_cursor_sprite = Sprite2D.new()
	aim_cursor_sprite.name = "Aim Cursor Sprite"
	if cursor_custom_parent:
		cursor_custom_parent.add_child(aim_cursor_sprite, false, Node.INTERNAL_MODE_BACK)
	else:
		self.add_child(aim_cursor_sprite, false, Node.INTERNAL_MODE_BACK)
	if cursor_material:
		aim_cursor_sprite.material = cursor_material
	
	set_cursor_scale(cursor_scale)
	set_cursor_sprite(cursor_texture_index)
	set_cursor_color(cursor_color)
	
	# place cursor in start position
	cursor_world_pos = player.global_position + cursor_start_world_offset
	aim_cursor_sprite.global_position = aim_cursor_sprite.get_viewport().get_canvas_transform() * cursor_world_pos
	
	camera_ref = get_viewport().get_camera_2d()

func _process(_delta: float) -> void:
	if OS.has_feature("editor"):
		if Input.is_action_just_pressed("NextAimReticle"):
			next_cursor_sprite()
		if Input.is_action_just_pressed("IncreaseReticleSize"):
			set_cursor_scale(cursor_scale + scale_step)
		if Input.is_action_just_pressed("DecreaseReticleSize"):
			set_cursor_scale(cursor_scale - scale_step)
		# toggle cursor lock
		if Input.is_action_just_pressed("ReleaseCursor"):
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# move cursor in a ciruclar area around player
	cursor_world_pos = player.global_position + cursor_world_offset
	aim_cursor_sprite.global_position = aim_cursor_sprite.get_viewport().get_canvas_transform() * cursor_world_pos
	
	# update helper positions
	if cursor_world_pos_helper:
		cursor_world_pos_helper.global_position = cursor_world_pos
	if cursor_camera_follow_helper:
		match camera_helper_placement_mode:
			CamHelperMode.FOLLOW_CURSOR:
				cursor_camera_follow_helper.global_position = cursor_world_pos
			CamHelperMode.FOLLOW_MIDDLE_POINT:
				var direction: Vector2 = Vector2(cursor_world_pos - player.global_position)
				var halfway_point: Vector2 = direction.limit_length(
						(middle_point_alpha * player.global_position.distance_to(cursor_world_pos))
					)
				cursor_camera_follow_helper.global_position = player.global_position + halfway_point

func _input(event: InputEvent) -> void:
	# update cursor world offset
	var mouse_delta = Vector2.ZERO
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
		var new_offset: Vector2 = cursor_world_offset + (mouse_delta * cursor_sensitivity_multiplier)
		if camera_ref:
			new_offset = cursor_world_offset + ((mouse_delta * cursor_sensitivity_multiplier) / camera_ref.zoom.x) # make sure cursor moves at same speed at all camera zoom levels
		else:
			new_offset = cursor_world_offset + (mouse_delta * cursor_sensitivity_multiplier)
		cursor_world_offset = new_offset.limit_length(cursor_max_distance_from_player)

func set_cursor_scale(new_scale:float):
	cursor_scale = clampf(new_scale, scale_min, scale_max)
	aim_cursor_sprite.global_scale = Vector2(cursor_scale, cursor_scale)

func set_cursor_sprite(index:int):
	aim_cursor_sprite.texture = cursor_sprite_options[index]
	cursor_texture_index = index

func next_cursor_sprite():
	var i = cursor_texture_index + 1
	if i >= cursor_sprite_options.size():
		i = 0
	aim_cursor_sprite.texture = cursor_sprite_options[i]
	cursor_texture_index = i

func set_cursor_color(new_color: Color):
	aim_cursor_sprite.modulate = new_color
