class_name Character
extends CharacterBody2D

func update_character_physics():
	pass # To be overridden in child classes

func _physics_process(delta):
	update_character_physics()
	move_and_slide()
