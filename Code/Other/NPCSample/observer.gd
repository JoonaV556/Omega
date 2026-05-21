class_name Observer
extends Node2D

@export var forget_seconds: float = 4.0

## args: dict of detected observables
signal on_detected_updated(detected: Array[Observable])
signal on_undetected(observable)

## currently detected observables [br]
## structure: [Observable, TimePassedSinceLastObserved]
var detected: Dictionary[Observable, float] = { }

func _physics_process(delta: float) -> void:
	self._pre_physics_process()

	# try detect new observables
	var candidates = get_detection_candidates()

	for candy: Observable in candidates:
		if can_detect(candy):
			detect(candy)

	# handle already remembered observables
	update_detected(delta)

func _pre_physics_process():
	pass

func update_detected(delta: float):
	var to_forget: Array[Observable]

	for _observable: Observable in detected:
		# forget old observables if they havent been detected for some time
		if detected[_observable] > forget_seconds:
			to_forget.append(_observable)
			continue

		# update time passed since the observable has been detected
		if can_detect(_observable):
			detected[_observable] = 0.0
		else:
			detected[_observable] += delta

	for _obs in to_forget:
		undetect(_obs)

func detect(observable: Observable):
	if detected.has(observable):
		return
	detected[observable] = 0.0
	on_detected_updated.emit(detected.keys())

func undetect(observable: Observable):
	detected.erase(observable)
	on_detected_updated.emit(detected.keys())
	on_undetected.emit(observable)

## Override in inheriting classes
func get_detection_candidates() -> Array[Observable]:
	return []

## Override in inheriting classes
func can_detect(observable: Observable) -> bool:
	return false
