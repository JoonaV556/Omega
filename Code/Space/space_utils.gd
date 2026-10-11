class_name SpaceUtils
extends RefCounted


static func get_object_type_string(object: StellarObject) -> String:

    if object is System:
        return "System"

    if object is Planet:
        return "Planet"

    return "Unknown"