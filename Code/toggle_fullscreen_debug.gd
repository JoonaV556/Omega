extends Node
# if in editor and esc is pressed, close game
func _process(_delta: float) -> void:
	if OS.has_feature("editor") and Input.is_action_just_pressed("ToggleWindowMode"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
