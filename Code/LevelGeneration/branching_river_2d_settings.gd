class_name BranchingRiver2DSettings
extends RefCounted

var direction : Tunneler2D.move_direction = Tunneler2D.move_direction.none

var max_branches : int = 1

var split_segment_length : int = 2

var split_segment_length_min : int
var split_segment_length_max : int

var bounds_min : Vector2i = Vector2i(0, 0)

## upper bounds of y and x components. if world grid is size 10x10 tiles, bounds_max should be 9, 9 
var bounds_max : Vector2i = Vector2i(10, 10)

