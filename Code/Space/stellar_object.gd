class_name StellarObject
extends RefCounted

var name : String

var objects : Array[StellarObject]

var local_coords : Vector2

## parent of this obejct
var so_parent : StellarObject


func _init(_coords : Vector2, _name : String = 'stellar_object') -> void:
    local_coords = _coords
    name = _name


func get_parent() -> StellarObject:
    return so_parent


## Returns all parents in parent chain for this object, excluding the object itself
func get_parents_recursive() -> Array[StellarObject]:
    var parents : Array[StellarObject] = []
    var current = self

    while true:
        var parent : StellarObject = current.get_parent()
        
        if !parent:
            break

        parents.append(parent)

        current = parent

    return parents