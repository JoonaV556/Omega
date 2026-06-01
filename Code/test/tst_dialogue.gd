## An utility node for initiating dialogues during gameplay
class_name TimelineStarter
extends Node

@export var timeline: DialogicTimeline

signal on_dialogue_ended

func start():
	if Dialogic.current_timeline != null:
		return

	Dialogic.start(timeline)
	
	await Dialogic.timeline_ended
	
	on_dialogue_ended.emit()
