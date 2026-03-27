class_name DebugCircle
extends Node2D

func _draw() -> void:
	self.draw_circle(Vector2(0,0), 1.0, Color.MEDIUM_VIOLET_RED, true)
	print("drew debug circle")
