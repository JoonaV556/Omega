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

const scale_min: float = 0.01
const scale_max: float = 100.0
const scale_step: float = 0.1

## start pos relative to player
const cursor_start_position: Vector2 = Vector2(0.0, 0.0)
## cursor position relative to player
var cursor_world_offset: Vector2 = Vector2(0, 0)

var aim_cursor_sprite: Sprite2D

func _ready() -> void:
	# hide system cursor
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
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

func _process(_delta: float) -> void:
	# move cursor in a ciruclar area around player
	#aim_cursor_sprite.global_position = aim_cursor_sprite.get_global_mouse_position()
	#update_cursor_world_poition()
	
	if OS.has_feature("editor"):
		if Input.is_action_just_pressed("NextAimReticle"):
			next_cursor_sprite()
		if Input.is_action_just_pressed("IncreaseReticleSize"):
			set_cursor_scale(cursor_scale + scale_step)
		if Input.is_action_just_pressed("DecreaseReticleSize"):
			set_cursor_scale(cursor_scale - scale_step)
	
	var cursor_world_pos = player.global_position + cursor_world_offset
	aim_cursor_sprite.global_position = aim_cursor_sprite.get_viewport().get_canvas_transform() * cursor_world_pos

func _input(event: InputEvent) -> void:
	### move cursor in a ciruclar area around player
	var mouse_delta = Vector2.ZERO
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
		var new_offset: Vector2 = cursor_world_offset + (mouse_delta * cursor_sensitivity_multiplier)
		cursor_world_offset = new_offset.limit_length(cursor_max_distance_from_player)

#func update_cursor_world_poition():
	## cursor_world_po = new_pos.limit_length(cursor_max_distance_from_player)
	##var new_pos: Vector2 = aim_cursor_sprite.get_global_mouse_position() - player.global_position
	#cursor_world_offset = Vector2(aim_cursor_sprite.get_global_mouse_position() - player.global_position).limit_length(cursor_max_distance_from_player)
	#var new_pos: Vector2 = get_viewport().get_mouse_position() - player.get_global_transform_with_canvas().get_origin()
	#var limited = new_pos.limit_length(cursor_max_distance_from_player)
	#aim_cursor_sprite.global_position = player.get_global_transform_with_canvas().get_origin() + limited

# cursor pos in game space
# set 

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
