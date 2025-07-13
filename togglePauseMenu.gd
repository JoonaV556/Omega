extends CanvasLayer

func _process(delta):
	if Input.is_action_just_released("TogglePauseMenu"):
		_toggle()
func _toggle():
	print("toggled pause menu")
