class_name StellarObjectPathUI
extends HBoxContainer

@export var _theme : Theme
@export var _label_settings : LabelSettings


signal on_path_button_pressed_for_stellar_object(object : StellarObject)


func show_path_for_object(_object : StellarObject):
	for c in get_children():
		c.queue_free()

	self._theme = _theme

	var path : Array[StellarObject] = [_object]
	path.append_array(_object.get_parents_recursive())

	for obj : StellarObject in path:
		var btn : Button = Button.new()
		btn.text = obj.name
		btn.flat = true
		btn.theme = _theme

		btn.pressed.connect(
			func():
				on_path_button_pressed_for_stellar_object.emit(obj)
		)

		var separator_label : Label = Label.new()
		separator_label.text = "/"
		separator_label.theme = _theme
		separator_label.label_settings = _label_settings

		add_child(btn)
		move_child(btn, 0)
		add_child(separator_label)
		move_child(separator_label, 0)

	print('Showed path for stellar object named %s' % [_object.name])
