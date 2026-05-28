class_name TimelineStarter
extends Node

@export var tmln: DialogicTimeline

func start():
	if Dialogic.current_timeline != null:
		return
	# # Create & Start a Dialogic timeline.
	# var events : Array = []
	# var text_event = DialogicTextEvent.new()
	# text_event.text = inspect_description

	# var evt2 = DialogicTextEvent.new()
	# evt2.text = "Poo"

	# events.append(text_event)
	# events.append(evt2)
	var timeline: DialogicTimeline = tmln
	timeline.events_processed = true
	Dialogic.start(timeline)
