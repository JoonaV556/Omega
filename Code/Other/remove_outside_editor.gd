class_name DebugRemoveOutsideEditor
extends Node

func _ready():
	get_parent().queue_free.call_deferred()
	
