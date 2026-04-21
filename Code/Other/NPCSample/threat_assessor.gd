## Determines if owner is in threat based on factions of currently detected observables
## [br] useful for civilian AI etc.
class_name ThreatAssessor
extends Node

@export var threatened: bool = false
@export var threat_source_pos: Vector2

var threat_source: Observable

var slf_fac_idx

func _ready():
	# get self identity
	slf_fac_idx = get_parent().get_meta("faction_index")

## connect with signal
func on_detected_updated(detected: Array[Observable]):
	if (detected.size() == 0) and threatened:
		threatened = false
		threat_source = null
		threat_source_pos = Vector2.ZERO
		return
	
	if threat_source and detected.has(threat_source):
		return
	
	for obs in detected:
		# get obs identity
		var obs_fac_idx = obs.get_parent().get_meta("faction_index")

		# if hostile - set threat
		var relation = FactionRelations.instance.get_relation_idx(slf_fac_idx, obs_fac_idx)
		
		if relation < 0:
			threatened = true
			threat_source = obs
			threat_source_pos = obs.global_position
			break
		else:
			threatened = false
			threat_source = null
			threat_source_pos = Vector2.ZERO
			break
