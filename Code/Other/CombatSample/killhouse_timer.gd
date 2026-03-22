class_name KillhouseTimer
extends Node

var time_seconds:float = 0.0
var running: bool = false

signal started 
signal stopped(time_passed)

func _process(delta: float) -> void:
	if running:
		time_seconds += delta

func start_timer():
	if running: 
		return
	time_seconds = 0.0
	running = true
	started.emit()

func stop_timer():
	if !running:
		return
	running = false
	stopped.emit(time_seconds)
