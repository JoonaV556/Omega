extends Label

func _ready() -> void:
	var txt = text
	text = "%s %s" % [txt, ProjectSettings.get_setting("application/config/version")]
