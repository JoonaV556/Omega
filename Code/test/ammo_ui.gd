extends RichTextLabel

@export var gun: Gun

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.text = str(str(gun.bullets_in_chamber)+" /"+str(gun.magazine_size))
