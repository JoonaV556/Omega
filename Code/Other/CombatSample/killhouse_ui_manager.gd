extends Node

@export var timer_label: RichTextLabel
@export var kills_label: RichTextLabel
@export var restart_hint_label: RichTextLabel

@export var timer: KillhouseTimer
@export var manager: KillhouseManager

func _ready() -> void:
	restart_hint_label.visible = false

func _process(delta: float) -> void:
	timer_label.text = str("%.2f" % timer.time_seconds)
	kills_label.text = str(str(manager.targets_killed)+" /"+str(manager.kills_required))

func on_restart():
	restart_hint_label.hide()

func on_completed():
	restart_hint_label.show()
