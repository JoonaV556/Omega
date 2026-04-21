@tool
extends BTAdjustableAction
## AdjustTest

@export var run_for_secs: float = 10.0
var ran_for = 0.0
var ticks: int = 0

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "AdjustTest"
	
func _adjusted_enter() -> void:
	ran_for = 0.0
	ticks = 0

func _adjusted_tick(delta: float) -> Status:
	if ran_for >= run_for_secs:
		print("done, executed total: "+str(ticks)+" ticks")
		print("runtime: "+str(elapsed_time)+" seconds")
		return SUCCESS
	else:
		ran_for = self.elapsed_time
		ticks += 1
		return RUNNING

# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
