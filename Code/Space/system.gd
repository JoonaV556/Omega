## Space based system. usually located in clusters inside galaxies. Not StarSystem because star systems consist mostly of stars IRL
class_name System
extends StellarObject

## objects[n][0] = object: [class StellarObject], [br] 
## objects[n][1] = object.local_position: [class Vector2] [br]
var objects: Array[StellarObject]

var primary_object: StellarObject


func _init(_name: String, _pivot_object: StellarObject = null) -> void:
	name = _name
	primary_object = _pivot_object



