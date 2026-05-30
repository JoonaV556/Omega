class_name GameCamera
extends Camera2D

static var instance: GameCamera

func _ready() -> void:
	if instance == null:
		instance = self
	elif instance != self:
		push_error("WARNING: multiple game cameras!!!!")
