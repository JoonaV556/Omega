class_name DBGShowInGame
extends Node

@export var target: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target.visible = true
