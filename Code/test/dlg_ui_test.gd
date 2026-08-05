extends Node

var ds: DialogueStarter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ds = %DialogueStarter
	ds.on_dialogue_started.connect(on_start)
	ds.on_dialogue_ended.connect(on_end)
	
	ds.start.call_deferred()

func on_start():
	# # get text box layer
	# await Dialogic.timeline_started
	# await Dialogic.Styles.style_changed
	# var ltb: OLayoutBase = Dialogic.Styles.get_layout_node() as OLayoutBase
	# var tbl: OTextBoxLayer = ltb.get_layer(3) as OTextBoxLayer
	# # move ups
	# await Dialogic.event_handled
	# tbl.move_up()
	# tbl.notify()
	# print(tbl.name)

	# var layers_all = Dialogic.Styles.get_layout_node().get_children()
	# var layers_intended = Dialogic.Styles.get_layout_node().get_layers()
	# print("retrieved all children")

	# await Dialogic.event_handled
	# tbl.move_up()
	# tbl.notify()
	# print(tbl.name)

	# await Dialogic.event_handled
	# tbl.move_up()
	# tbl.notify()
	# print(tbl.name)
	pass
	
func on_end():
	pass
