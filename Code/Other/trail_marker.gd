class_name TrailMarker
extends Node2D 

@export var target: Node2D

@export var trail_distance: float = 1.5*16.0

@export var target_move_treshold: float = 0.05

@export var active = false

var t_move_dir: Vector2 = Vector2.RIGHT

var t_last_pos: Vector2 = Vector2.ZERO

func _ready():
    t_last_pos = target.global_position

func _process(delta):
    if active:
        var moved = target.global_position.distance_to(t_last_pos)
        if moved > target_move_treshold:
            t_move_dir = t_last_pos.direction_to(target.global_position).normalized()
            var t_pos: Vector2 = target.global_position + (-1 * t_move_dir * trail_distance)
            self.global_position = t_pos
            t_last_pos = target.global_position
