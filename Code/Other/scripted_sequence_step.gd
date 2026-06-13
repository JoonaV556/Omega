class_name ScriptedSequenceStep
extends Node

signal on_start
signal on_completed

var started = false
var completed = false

func start():
	if started:
		push_error("cant start. already started")
		return

	started = true
	on_start.emit()

func complete():
	if !started:
		push_error("cant complete. not yet started")
		return

	completed = true
	on_completed.emit()
