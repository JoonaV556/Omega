extends Node
# Provides a short inspect description for in-world items, by utilizing Dialogic. 

@export var inspect_description: String = "I am looking at something but I don't know what it is."

func _on_interactable_interact():
	if Dialogic.current_timeline != null:
		return
	# Create & Start a Dialogic timeline.
	var events : Array = []
	var text_event = DialogicTextEvent.new()
	text_event.text = inspect_description
	events.append(text_event)
	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = events
	timeline.events_processed = true
	Dialogic.start(timeline)
