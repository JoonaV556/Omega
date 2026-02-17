extends CanvasItem

func _ready() -> void:
	push_warning("DEBUG - made "+str(self.get_parent().name)+" visible on ready")
	self.set_visible(true)
