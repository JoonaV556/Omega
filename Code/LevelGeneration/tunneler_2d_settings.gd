class_name Tunneler2DSettings
extends RefCounted

var start_cell : Vector2i = Vector2i.ZERO
var initial_direction : Tunneler2D.move_direction = Tunneler2D.move_direction.N

var bounds_min : Vector2i = Vector2i(0, 0)
var bounds_max : Vector2i = Vector2i(10, 10)

var max_steps : int = 50
var min_steps_between_turns : int = 3 

var max_turns : int = 3
var turn_odds_percentage : float = 50.0