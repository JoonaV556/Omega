class_name Selector
extends Node

## Usage: [br]
## - Instantiate Selector and provide a tree node to attach to. [br]
## - Optionally provide a unique selector ID to _init(). [br]
## - Register selectable GUI Control nodes with register_selectable_control(). [br]
## - Register selectable Sprite2D nodes with register_selectable_sprite2d(). [br]
## - Optionally register an unselector Control (ideally a GUI background) with register_unselector_control(). [br]
## - Connect to on_selected and on_unselected to respond to changes. [br]
## Note: [br]
## Selectable controls must be able to receive focus. Do not place Control
## nodes in front of selectables if they intercept their GUI input events.


var selected : Node = null

var id : int = 0

const SELECTOR_META : StringName = StringName("selector_id")


signal on_selected(new_selection : Node)
signal on_selectable_rmb_clicked(selectable : Node)
signal on_unselected()


# attach_to: node in scene tree to attach the selector to - REQUIRED
func _init(attach_to : Node, selector_id : int = 0) -> void:
	id = selector_id
	attach_to.add_child(self)


func _ready() -> void:
	var vp = get_viewport()
	vp.gui_focus_changed.connect(_on_gui_focus_changed)


func _select(selectable : Node):
	selected = selectable
	on_selected.emit(selected)


func _unselect():
	selected = null
	on_unselected.emit()


func _on_gui_focus_changed(new_focus : Control):
	# Try _select 
	if !new_focus:
		return

	if !new_focus.has_meta(SELECTOR_META):
		return

	if new_focus.get_meta(SELECTOR_META) != id:
		return

	# its a valid selectable, hurray!
	_select(new_focus)


func _try_update_2d_selected(selectable : Selectable2D):
	if selected == selectable.get_parent():
		return

	_select(selectable.get_parent())


func _on_selectable_rmb_clicked(selectable : Selectable2D):
	on_selectable_rmb_clicked.emit(selectable.get_parent())
	

func register_selectable_control(control : Control):
	# Make the control focusable in viewport
	control.focus_mode = Control.FOCUS_CLICK
	control.mouse_filter = Control.MOUSE_FILTER_PASS

	# Allows us to see if the control is a selectable when focus changes
	control.set_meta(SELECTOR_META, id)


func register_selectable_sprite2d(sprite : Sprite2D):
	var selectable = Selectable2D.new(self)
	selectable.input_pickable = true
	
	var collision_shape : CollisionShape2D = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	var sprite_texture_half_width = sprite.texture.get_width() / 2.0
	circle.radius = sprite_texture_half_width
	collision_shape.shape = circle

	selectable.add_child(collision_shape)
	
	sprite.add_child(selectable)


func register_unselector_control(unselector : Control):
	# Make the control focusable in viewport
	unselector.focus_mode = Control.FOCUS_CLICK
	unselector.mouse_filter = Control.MOUSE_FILTER_PASS

	unselector.gui_input.connect(
		func(event : InputEvent):
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					_unselect()
	)
