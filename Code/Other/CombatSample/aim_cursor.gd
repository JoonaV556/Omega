## Cursor reticle suitable for weapons / aiming.
class_name AimCursor
extends Node

@export var cursor_options: Array[Texture2D]

@export_range(0.01, 100.0) var cursor_scale: float = 1.0

@export var cursor_color: Color = Color.WHITE

@export var cursor_texture_index:int = 0

const scale_min: float = 0.01
const scale_max: float = 100.0
const scale_step: float = 0.1

var aim_cursor_sprite: Sprite2D

func _ready() -> void:
	# hide system cursor
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	# create aim cursor 
	aim_cursor_sprite = Sprite2D.new()
	aim_cursor_sprite.name = "Aim Cursor Sprite"
	self.add_child(aim_cursor_sprite, false, Node.INTERNAL_MODE_BACK)

	set_cursor_scale(cursor_scale)
	set_cursor_sprite(cursor_texture_index)
	set_cursor_color(cursor_color)

func _process(_delta: float) -> void:
	aim_cursor_sprite.global_position = aim_cursor_sprite.get_global_mouse_position()
	
	if Input.is_action_just_pressed("NextAimReticle"):
		next_cursor_sprite()
	if Input.is_action_just_pressed("IncreaseReticleSize"):
		set_cursor_scale(cursor_scale + scale_step)
	if Input.is_action_just_pressed("DecreaseReticleSize"):
		set_cursor_scale(cursor_scale - scale_step)

func set_cursor_scale(new_scale:float):
	cursor_scale = clampf(new_scale, scale_min, scale_max)
	aim_cursor_sprite.global_scale = Vector2(cursor_scale, cursor_scale)

func set_cursor_sprite(index:int):
	aim_cursor_sprite.texture = cursor_options[index]
	cursor_texture_index = index

func next_cursor_sprite():
	var i = cursor_texture_index + 1
	if i >= cursor_options.size():
		i = 0
	aim_cursor_sprite.texture = cursor_options[i]
	cursor_texture_index = i

func set_cursor_color(new_color: Color):
	aim_cursor_sprite.modulate = new_color
