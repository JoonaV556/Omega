class_name ViewedObejctHint
extends Label

func set_hint(object : HStellarObject):
	show()
	var type : String = "stellar object"
	
	if object is HGalaxy:
		type = "galaxy"
	if object is HSystem:
		type = "star system"
	
	text = String("Viewing local map for %s %s" % [type, object.name])
