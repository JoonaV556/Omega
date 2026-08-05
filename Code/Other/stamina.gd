class_name Stamina
extends Node

@export var deplete_per_sec = 3.0

@export var deplete         = false

@export var regen_per_sec   = 5.0

@export var stamina         = 100.0

@export var stamina_cap     = 100.0

@export var regen_signal_treshold = stamina_cap / 2.0

signal on_depleted
signal on_full_replenish
signal on_replenished_over_treshold
signal on_stamina_updated(stam, max_stam)

func _ready():
	stamina = stamina_cap

	on_stamina_updated.emit(stamina, stamina_cap)

func _process(delta):
	if deplete:
		var pre_d = stamina
		var new_s = stamina - (deplete_per_sec * delta)
		
		if new_s < 0.0:
			stamina = 0.0

			 # stam completely depleted
			if pre_d > 0.0:
				on_depleted.emit()

		stamina = clampf(new_s, 0.0, stamina_cap)
	else:
		var pre_r = stamina

		var regen_amnt = regen_per_sec * delta

		# reached max stam
		if (pre_r < stamina_cap) and ((pre_r + regen_amnt) >= stamina_cap):
			on_full_replenish.emit()

		# regened past min deplete amount - useful for re-enabling sprinting etc. in other systems
		if (pre_r < regen_signal_treshold) and ((pre_r + regen_amnt) > regen_signal_treshold):
			on_replenished_over_treshold.emit()

		stamina = clampf(stamina + (regen_amnt), 0.0, stamina_cap)
	
	on_stamina_updated.emit(stamina, stamina_cap)
		
func enable_deplete():
	deplete = true

func disable_deplete():
	deplete = false
