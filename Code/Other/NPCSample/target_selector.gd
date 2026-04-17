## Selects a target of interest, useful for aggression logic
class_name TargetSelector
extends Node

@export var observer: Observer 

var target: Node2D

@export var _has_target: bool = false
@export var target_pos: Vector2

func _ready() -> void:
	observer.on_detected_updated.connect(on_target_candidates_updated)
	observer.on_undetected.connect(_on_undetected)

## selects new target
func on_target_candidates_updated(candidates: Dictionary):
	if target:
		return
	if candidates.size() > 0:
		if candidates.keys()[0] != null:
			select(candidates.keys()[0])	

func select(_target: Node2D):
	target = _target
	_has_target = true

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
