class_name StellarObject
extends RefCounted

var name : String

var objects : Array[StellarObject]

var local_coords : Vector2


func _init(_coords : Vector2, _name : String = 'stellar_object') -> void:
    local_coords = _coords
    name = _name