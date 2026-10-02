class_name HStellarObject
extends RefCounted

var name : String

var objects : Array[HStellarObject]

var local_coords : Vector2

## parent of this obejct
var so_parent : HStellarObject


func _init(_coords : Vector2, _name : String = 'stellar_object') -> void:
    local_coords = _coords
    name = _name


func get_parent() -> HStellarObject:
    return so_parent


## Returns all parents in parent chain for this object, excluding the object itself
func get_parents_recursive() -> Array[HStellarObject]:
    var parents : Array[HStellarObject] = []
    var current = self

    while true:
        var parent : HStellarObject = current.get_parent()
        
        if !parent:
            break

        parents.append(parent)

        current = parent

    return parents