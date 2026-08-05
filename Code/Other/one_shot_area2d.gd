class_name OneShotArea2D
extends Area2D

signal on_body_entered_one_shot(body: Node2D)

var b_entered = false

func _ready():
	self.body_entered.connect(trigger)

func trigger(body):
	if !b_entered:
		on_body_entered_one_shot.emit(body)
		b_entered = true
