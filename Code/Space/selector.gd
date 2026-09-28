class_name Selector
extends Node

## USAGE
# Instantiate
# Add to tree
# register selectables
## Ensure there are no control nodes in front of selectables in tree which stop gui input events


var selected : Node = null

var id : int = 0


const SELECTOR_META : StringName = StringName("selector_id")


signal on_selected(new_selection : Node)


func _init(selector_id : int = 0) -> void:
	id = selector_id


func _ready() -> void:
	var vp = get_viewport()
	vp.gui_focus_changed.connect(try_update_gui_selected)


func select(selectable : Node):
	selected = selectable
	on_selected.emit(selected)


func try_update_gui_selected(new_focus : Control):
	if !new_focus:
		return

	if !new_focus.has_meta(SELECTOR_META):
		return

	if new_focus.get_meta(SELECTOR_META) != id:
		return

	# its a valid selectable, hurray!
	select(new_focus)


func try_update_2d_selected(selectable : Selectable2D):
	if selected == selectable.get_parent():
		return

	select(selectable.get_parent())


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
