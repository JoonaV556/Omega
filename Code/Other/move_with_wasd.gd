class_name MoveWithWASD
extends Node

var trg : Node2D

@export var move_speed_per_sec : float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trg = self.get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_W):
		trg.translate(Vector2(0, -1 * delta * move_speed_per_sec))
	if Input.is_key_pressed(KEY_S):
		trg.translate(Vector2(0, 1 * delta * move_speed_per_sec))
	if Input.is_key_pressed(KEY_A):
		trg.translate(Vector2(-1 * delta * move_speed_per_sec, 0))
	if Input.is_key_pressed(KEY_D):
		trg.translate(Vector2(1 * delta * move_speed_per_sec, 0))
