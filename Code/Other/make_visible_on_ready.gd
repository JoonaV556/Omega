extends CanvasItem
@export var enabled: bool = false
func _ready() -> void:
	if !enabled:
		return
	push_warning("DEBUG - made "+str(self.get_parent().name)+" visible on ready")
	self.set_visible(true)
