class_name Character
extends CharacterBody2D

## pixels per second
@export var move_speed: float = 100 

func update_character_physics():
	pass # To be overridden in child classes

func _physics_process(_delta):
	update_character_physics()
	move_and_slide()
