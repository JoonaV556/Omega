class_name ObjectInfoLabel
extends Label


func _ready() -> void:
	hide()


func show_info(obj: StellarObject):
	show()
	var _str := String("Object Info 
	\n\t type: %s
	\n\t name: %s
	" % [SpaceUtils.get_object_type_string(obj), obj.name])

	text = _str
