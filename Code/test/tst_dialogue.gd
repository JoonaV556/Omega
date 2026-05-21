extends Node
# Provides a short inspect description for in-world items, by utilizing Dialogic. 

@export var inspect_description: String = "I am looking at something but I don't know what it is."
@export var tmln: DialogicTimeline

func _ready():
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
