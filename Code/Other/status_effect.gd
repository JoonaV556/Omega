class_name StatusEffect
extends RefCounted

## seconds
var duration = 5.0
## seconds
var time_left
var completed = false
var receiver: StatusEffectReceiver

func _init(_duration: float):
    duration = _duration
    time_left = duration
    completed = false

func update(delta_seconds: float):
    if completed:
        return 

    if (time_left - delta_seconds) <= 0:
        time_left = 0.0
        completed = true
    else:
        time_left -= delta_seconds

func start(_receiver: StatusEffectReceiver):
    receiver = _receiver 
    _start()

func end():
    _end()

func get_receiver() -> StatusEffectReceiver:
    return receiver

## override in inheriting
func _start():
    pass

## override in inheriting
func _end():
    pass