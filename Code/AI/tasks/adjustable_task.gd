@tool
extends BTAction
## BTAction with adjustable tick-rate. 
## [br] DO NOT OVERRIDE _setup(), _enter() nor _tick()
## [br] Use _adjusted_setup(), _adjusted_enter(), and _adjusted_tick(delta: float) instead
class_name BTAdjustableAction
## BTAction with adjustable tick-rate. 
## [br] DO NOT OVERRIDE _setup(), _enter() nor _tick()
## [br] Use _adjusted_setup(), _adjusted_enter(), and _adjusted_tick(delta: float) instead

@export var max_ticks_per_second: int = 60
var secs_between_ticks: float
var secs_since_last_tick: float = 0.0
var accumulated_delta: float = 0.0
var last_status: Status

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "AdjustableTask"

# Called once during initialization.
func _setup() -> void:
	secs_between_ticks = 1.0 / max_ticks_per_second
	secs_since_last_tick = secs_between_ticks + 0.1 # ensures adjusted tick is ran on first tick
	accumulated_delta = 0.0
	_adjusted_setup()

## override in children
func _adjusted_setup() -> void:
	pass

# Called each time this task is entered.
func _enter() -> void:
	secs_between_ticks = 1.0 / max_ticks_per_second
	secs_since_last_tick = secs_between_ticks + 0.1 # ensures adjusted tick is ran on first tick
	accumulated_delta = 0.0
	last_status = self.RUNNING
	_adjusted_enter()

## override in children
func _adjusted_enter() -> void:
	pass

# Called each time this task is exited.
func _exit() -> void:
	pass

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	if secs_since_last_tick >= secs_between_ticks:
		var retrn = _adjusted_tick(accumulated_delta)
		last_status = retrn
		secs_since_last_tick = 0.0
		accumulated_delta = 0.0
		return retrn
	else:
		secs_since_last_tick += delta
		accumulated_delta += delta
		return last_status

## override in children
func _adjusted_tick(delta: float) -> Status:
	return SUCCESS

# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
