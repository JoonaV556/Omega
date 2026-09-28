class_name Selector
extends Node

## USAGE
# Instantiate
# Add to tree
# register selectables
## Ensure there are no control nodes in front of selectables in tree which stop gui input events


var selected : Control = null

var id : int = 0


const SELECTOR_META : StringName = StringName("selector_id")


signal on_selected(new_selection : Control)


func _init(selector_id : int = 0) -> void:
	id = selector_id


func _ready() -> void:
	var vp = get_viewport()
	vp.gui_focus_changed.connect(try_update_selected)


func try_update_selected(new_focus : Control):
	if !new_focus:
		return

	if !new_focus.has_meta(SELECTOR_META):
		return

	if new_focus.get_meta(SELECTOR_META) != id:
		return

	# its a valid selectable, hurray!
	selected = new_focus
	on_selected.emit(selected)


func register_selectable_control(control : Control):
	# Make the control focusable in viewport
	control.focus_mode = Control.FOCUS_CLICK
	control.mouse_filter = Control.MOUSE_FILTER_PASS

	# Allows us to see if the control is a selectable when focus changes
	control.set_meta(SELECTOR_META, id)
