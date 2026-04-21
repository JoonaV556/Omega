class_name FactionRelations
extends Resource

## factions factions[faction]
@export var factions: Array[Faction]

## Array[Array[float]], where float is rel[x] relation to rel[y]
@export var relations: Array[float]

#   a   b   c
# a 0.5 1.0 2.0
# b
# c

static var instance: FactionRelations

const relation_default: float = 1.0

func _init() -> void:
    if !instance:
        instance = self

func get_faction_idx(identity: FactionIdentity):
    return factions.find(identity.faction)

## returns the relation number of faction_a relative to faction_b
func get_relation(faction_a: Faction, faction_b: Faction) -> float:
    var idx_a = factions.find(faction_a)
    var idx_b = factions.find(faction_b)

    if (idx_a < 0) or (idx_b < 0):
        push_error("cant find one or the other supplied factions. Probably not defined in factions resource")
        return -9.0

    return get_relation_idx(idx_a, idx_b)

func get_relation_idx(faction_idx_a, faction_idx_b) -> float:
    if (faction_idx_a < 0) or (faction_idx_b < 0):
        push_error("invalid faction index")
        return -9.0
    if (faction_idx_a >= factions.size()) or (faction_idx_b >= factions.size()):
        push_error("invalid faction index")
        return -9.0    
    return relations[(factions.size()*faction_idx_a)+faction_idx_b]