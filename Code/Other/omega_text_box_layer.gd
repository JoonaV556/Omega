@tool
extends TextBoxLayer
class_name OTextBoxLayer

var anch_pos_pre_move

func move_up():
	var anch: Control = get_node("%Anchor")

	# attach to top of the screen
	anch_pos_pre_move = anch.position
	anch.set_anchors_preset(Control.LayoutPreset.PRESET_CENTER_TOP, true)

	## bring down so tbox is not left above screen edge
	## TODO - fix at some point
	## -take into account total size of the tbox, including name label
	## -make top_extra_margin 
	const top_extra_margin = 100
	anch.position = anch.position + Vector2(0, box_size.y + top_extra_margin) 
	
	# simple implementation ??
	# anch.position = anch.position + Vector2(0, -300)
	print("moved tbox up")

func move_down():
	var anch: Control = get_node("%Anchor")
	anch.set_anchors_preset(Control.LayoutPreset.PRESET_CENTER_BOTTOM, true)
	anch.position = anch_pos_pre_move
	print("moved tbox down")

func hide():
	var anch: Control = get_node("%Anchor")
	anch.hide()
	
