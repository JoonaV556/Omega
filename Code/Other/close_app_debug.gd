class_name DebugCloseApp
extends Node

@export var editor_only = true

# if in editor and esc is pressed, close game
func _process(_delta: float) -> void:
	if editor_only and !OS.has_feature("editor"):
		return

	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
