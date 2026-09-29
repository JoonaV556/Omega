class_name Selectable2D
extends Area2D

var selector : Selector


func _init(_selector) -> void:
	selector = _selector

func _ready() -> void:
	input_event.connect(
		func(vp, event : InputEvent, shape_idx):
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					selector._try_update_2d_selected(self)
				if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
					selector._on_selectable_rmb_clicked(self)
	)
