## Status effect which slows down receivers movement speed
class_name SEImpairMovement
extends StatusEffect

var character: Character

func _start():
    # get char
    var _char := receiver.get_parent() as Character
    if _char:
        character = _char

    # slow char down 
    character.move_speed_multiplier = 0.5

func _end():
    # return speed to normal
    character.move_speed_multiplier = 1.0