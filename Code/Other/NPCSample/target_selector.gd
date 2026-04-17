## Selects a target of interest, useful for aggression logic
class_name TargetSelector
extends Node

@export var observer: Observer 

var target: Node2D

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

func _on_undetected(obs: Observable):
	# forget target if it was undetected
	if target == obs:
		target = null
	# try select new one
	try_reselect()

func _process(delta: float) -> void:
	if !target:
		try_reselect()

func try_reselect():
	if observer.detected.size() > 0:
		if observer.detected.keys()[0] != null:
			select(observer.detected.keys()[0])
