@tool
class_name OLayoutBase
extends DialogicLayoutBase

var text_box_layer: OTextBoxLayer

func _ready():
	for l in get_layers():
		if l is OTextBoxLayer:
			text_box_layer = l