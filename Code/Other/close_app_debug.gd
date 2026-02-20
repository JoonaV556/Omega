class_name CloseApp
extends Node
# if in editor and esc is pressed, close game
func _process(_delta: float) -> void:
	if OS.has_feature("editor") and Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
