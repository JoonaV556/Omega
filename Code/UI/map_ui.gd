class_name MapUI
extends Control


var mode : MODE

signal on_mode_changed(new_mode : String)

enum MODE {
	Galaxy, 
	System
	}


func set_mode_int(new_mode : int):
	set_mode(new_mode as MODE)

func set_mode(new_mode : MODE):
	mode = new_mode
	on_mode_changed.emit(MODE.keys()[mode])
	print('Map mode changed to %s' % [MODE.keys()[mode]])
