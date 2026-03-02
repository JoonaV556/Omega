class_name ScoutingMapCellUI
extends ColorRect

var coords:Vector2i

signal on_clicked

func _gui_input(_event: InputEvent) -> void:
	if _event is InputEventMouseButton:
		if _event.button_index == MOUSE_BUTTON_LEFT and _event.pressed:
			on_clicked.emit(self)
