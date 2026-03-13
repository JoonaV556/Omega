## A simple toggleable flashlight for lighting dark environments
extends Node2D

@export var light:PointLight2D

signal on_toggled_on
signal on_toggled_off
signal on_toggled

func _ready() -> void:
	light.set_visible(false)

func _process(_delta: float) -> void:
	# toggle
	if Input.is_action_just_pressed("ToggleFlashlight"):
		if light.visible == true:
			light.set_visible(false)
			on_toggled_off.emit()
			on_toggled.emit()
		else:
			light.set_visible(true)
			on_toggled_on.emit()
			on_toggled.emit()
	
	# point where player is looking
	var mouse_pos = get_global_mouse_position()
	self.look_at(mouse_pos)
