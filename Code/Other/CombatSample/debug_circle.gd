class_name DebugCircle
extends Node2D

var radius 

func _init(_radius: float = 1.0) -> void:
	radius = _radius

func _draw() -> void:
	self.draw_circle(Vector2(0,0), radius, Color.MEDIUM_VIOLET_RED, true)
	print("drew debug circle")
