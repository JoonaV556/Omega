class_name Observer
extends Node2D

@export var forget_seconds: float = 4.0

@export var detected: Array[Observable]

## args: dict of _detected observables
signal on_detected_updated(detected: Array[Observable])

signal on_undetected(observable)

signal detected_out(det: Array[Observable])

## currently _detected observables [br]
## structure: [Observable, TimePassedSinceLastObserved]
var _detected: Dictionary[Observable, float] = { }

func _physics_process(delta: float) -> void:
	self._pre_physics_process()

	# try detect new observables
	var candidates = get_detection_candidates()

	for candy: Observable in candidates:
		if can_detect(candy):
			detect(candy)

	# handle already remembered observables
	update_detected(delta)

	detected = _detected.keys()
	detected_out.emit(detected)

func _pre_physics_process():
	pass

func update_detected(delta: float):
	var to_forget: Array[Observable]

	for _observable: Observable in _detected:
		# forget old observables if they havent been _detected for some time
		if _detected[_observable] > forget_seconds:
			to_forget.append(_observable)
			continue

		# update time passed since the observable has been _detected
		if can_detect(_observable):
			_detected[_observable] = 0.0
		else:
			_detected[_observable] += delta

	for _obs in to_forget:
		undetect(_obs)

func detect(observable: Observable):
	if _detected.has(observable):
		return
	_detected[observable] = 0.0
	on_detected_updated.emit(_detected.keys())

func undetect(observable: Observable):
	_detected.erase(observable)
	on_detected_updated.emit(_detected.keys())
	on_undetected.emit(observable)

## Override in inheriting classes
func get_detection_candidates() -> Array[Observable]:
	return []

## Override in inheriting classes
func can_detect(observable: Observable) -> bool:
	return false
