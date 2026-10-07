class_name UI
extends Control

var _active = false

func activate():
	self.show()
	_active = true


func deactivate():
	self.hide()
	_active = false


func toggle():
	if _active:
		deactivate()
	else:
		activate()