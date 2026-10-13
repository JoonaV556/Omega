## Space based system. usually located in clusters inside galaxies. Not StarSystem because star systems consist mostly of stars IRL
class_name System
extends SpaceObject

var objects: Array[SpaceObject]

var primary_object: SpaceObject


func _init(_name: String, _pivot_object: SpaceObject = null) -> void:
	name = _name
	primary_object = _pivot_object



