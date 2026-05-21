@tool
extends BTDecorator
## DecoratorFailIf

## ends itself if specified variable equals the boolean

@export var variable := &"pos"

@export var boolean: bool = false

@export var end_in: end_type = end_type.FAILURE

enum end_type {FAILURE, SUCCESS}

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Fail If"

# Called once during initialization.
func _setup() -> void:
	pass


# Called each time this task is entered.
func _enter() -> void:
	pass


# Called each time this task is exited.
func _exit() -> void:
	pass
	# self.get_child(0).abort()

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var _variable = blackboard.get_var(variable, null)
	
	var value := _variable as bool
	if !value:
		return FAILURE

	if value == boolean:
		match end_in:
			end_type.SUCCESS:
				return SUCCESS
			end_type.FAILURE:
				return FAILURE

	return self.get_child(0).execute(delta)


# Strings returned from this method are displayed as warnings in the behavior tree editor (requires @tool).
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
