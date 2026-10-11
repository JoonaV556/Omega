class_name UI
extends Control

var _active = false


signal on_activated
signal on_deactivated


func activate():
	self.show()
	_active = true
	on_activated.emit()


func deactivate():
	self.hide()
	_active = false
	on_deactivated.emit()


func toggle():
	if _active:
		deactivate()
	else:
		activate()