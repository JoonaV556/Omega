class_name Character
extends CharacterBody2D

## pixels per second
@export var walk_speed: 	float = 100 
@export var sprint_speed: 	float = 200

var current_move_speed

var sprinting = false

func _ready() -> void:
	current_move_speed = walk_speed

func update_character_physics():
	pass # To be overridden in child classes

func _physics_process(_delta):
	update_character_physics()
	move_and_slide()

func set_sprinting(val: bool):
	if val:
		sprinting = true
		current_move_speed = sprint_speed
	else:
		sprinting = false
		current_move_speed = walk_speed
