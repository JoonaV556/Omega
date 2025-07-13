extends CanvasLayer

# makes the property visible in inspector and allows assigning it in editor
@export var pauseMenuNode: CanvasLayer

# _process is called by engine once every frame, practically an update function for gdscripts
func _process(delta):
	# checks if input action named "TogglePauseMenu" in input maps is pressed this frame
	if Input.is_action_just_released("TogglePauseMenu"):
		_toggle()
func _toggle():
	if pauseMenuNode.is_visible():
		pauseMenuNode.hide()
	else:
		pauseMenuNode.show()

# visible [default: true]set_visible(value) setteris_visible() getter

# ● void hide()

# Hides any CanvasItem under this CanvasLayer. This
