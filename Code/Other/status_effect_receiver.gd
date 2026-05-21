class_name StatusEffectReceiver
extends Node

var active_effects: Array[StatusEffect]

func _process(delta):

    var completed = []
    # update effects
    for ef: StatusEffect in active_effects:
        ef.update(delta)
        if ef.completed:
            completed.append(ef)

    # remove completed effects
    for ef: StatusEffect in completed:
        ef.end()
        active_effects.erase(ef)

## apply new effect on the receiver
func apply_effect(effect: StatusEffect):
    active_effects.append(effect)
    effect.start(self)