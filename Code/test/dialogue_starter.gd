## An utility node for initiating dialogues during gameplay
class_name DialogueStarter
extends Node

@export var timeline: DialogicTimeline

## String: Listened dialogic event arg string [br]
## SignalOutput: Signal output node to trigger 
@export var dialogue_event_signal_output_nodes: Dictionary[String, SignalOutput]

signal on_dialogue_ended

func start():
	if Dialogic.current_timeline != null:
		return

	Dialogic.signal_event.connect(on_dialogic_signal_event)

	Dialogic.start(timeline)
	
	await Dialogic.timeline_ended
	
	on_dialogue_ended.emit()

	Dialogic.signal_event.disconnect(on_dialogic_signal_event)


func on_dialogic_signal_event(args):
	if args is not String:
		return
	
	var s_args = args as String

	if s_args in dialogue_event_signal_output_nodes:
		dialogue_event_signal_output_nodes[s_args].trigger()
