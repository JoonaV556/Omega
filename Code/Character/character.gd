class_name Character
extends CharacterBody2D

## pixels per second
@export var walk_speed: 	float = 100 
@export var sprint_speed: 	float = 200

signal on_sprinting_started
signal on_sprinting_stopped

## IF MODIFIED, REMEMBER TO RETURN BACK TO NORMAL 
var move_speed_multiplier: float = 1.0

var movement_enabled = true

var current_move_speed

var sprinting = false

var sprint_allowed = true

func _ready() -> void:
	current_move_speed = walk_speed

func update_character_physics():
	pass # To be overridden in child classes

func _physics_process(_delta):
	update_character_physics()
	self.velocity *= move_speed_multiplier
	move_and_slide()

func set_sprinting(val: bool):
	if val and sprint_allowed:
		if !sprinting:
			on_sprinting_started.emit()
		sprinting = true
		current_move_speed = sprint_speed
	else:
		if sprinting:
			on_sprinting_stopped.emit()
		sprinting = false
		current_move_speed = walk_speed

func enable_movement():
	movement_enabled = true
	_on_movement_enabled()

func disable_movement():
	movement_enabled = false
	_on_movement_disabled()

func allow_sprint(allow: bool):

	if !allow and sprinting:
		set_sprinting(false)
		
	sprint_allowed = allow

func _on_movement_disabled():
	pass

func _on_movement_enabled():
	pass
