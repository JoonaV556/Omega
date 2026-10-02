class_name ViewedObejctHint
extends Label

func set_hint(object : StellarObject):
	show()
	var type : String = "stellar object"
	
	if object is Galaxy:
		type = "galaxy"
	if object is System:
		type = "star system"
	
	text = String("Viewing local map for %s %s" % [type, object.name])
