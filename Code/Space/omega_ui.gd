class_name OmegaUI
extends CanvasLayer

@export var map_ui : UI


func _ready() -> void:
	map_ui.deactivate()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ToggleMap"):
		map_ui.toggle()
