extends Node

func text_box_move_up():
	var olayout = Dialogic.Styles.get_layout_node() as OLayoutBase

	if !olayout:
		push_warning("Cant find Dialogue OLayoutBase layout node. Current style probably doesnt support moveup")
		return

	for c in olayout.get_layers():
		if c is OTextBoxLayer:
			c.move_up()

func text_box_move_down():
	var olayout = Dialogic.Styles.get_layout_node() as OLayoutBase

	if !olayout:
		push_warning("Cant find Dialogue OLayoutBase layout node. Current style probably doesnt support movedown")
		return

	for c in olayout.get_layers():
		if c is OTextBoxLayer:
			c.move_down()
