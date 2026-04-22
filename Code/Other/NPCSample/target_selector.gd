## Selects a target of interest, useful for aggression logic
class_name TargetSelector
extends Node

@export var observer: Observer 

var target: Node2D

@export var _has_target: bool = false
@export var target_pos: Vector2

var self_faction: int

func _ready() -> void:
	observer.on_detected_updated.connect(on_target_candidates_updated)
	observer.on_undetected.connect(_on_undetected)
	self_faction = get_parent().get_meta("faction_index")

## selects new target
func on_target_candidates_updated(candidates: Array[Observable]):
	if target:
		return
	if candidates.size() > 0:
		if candidates[0] != null:
			select(candidates[0])	

func select(_target: Node2D) -> bool:
	# prevent targetting non-hostile faction members
	var target_faction = _target.get_parent().get_meta("faction_index")
	if not FactionRelations.instance.is_hostile(self_faction, target_faction):
		return false

	target = _target
	_has_target = true
	return true

func _on_undetected(obs: Observable):
	# forget target if it was undetected
	if target == obs:
		target = null
		_has_target = false
	# try select new one
	try_reselect()

func _process(delta: float) -> void:
	if !target:
		try_reselect()
		target_pos = Vector2.ZERO
	else:
		target_pos = target.global_position

func try_reselect():
	if observer.detected.size() > 0:
		if observer.detected.keys()[0] != null:
			select(observer.detected.keys()[0])

func has_target() -> bool:
	return _has_target
