## Node with custom tick interval. May skip ticks after long updates
@abstract class_name ThrottledNode 
extends Node


@export var seconds_between_ticks: float = 0.25

var _accumulated_delta: float = 0.0 


func _process(delta: float) -> void:
    _accumulated_delta += delta

    if _accumulated_delta >= seconds_between_ticks:
        _throttled_process(_accumulated_delta)

        _accumulated_delta -= seconds_between_ticks


@abstract
func _throttled_process(delta: float)