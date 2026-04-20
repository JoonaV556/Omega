extends Node

@export var fac_1: Faction
@export var fac_2: Faction
@export var fac_3: Faction
@export var fac_4: Faction
@export var fac_5: Faction
@export var fac_6: Faction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("getting relations ")
	print(str(GlobalGameData.faction_relations.get_relation(fac_1, fac_2)))
	print(str(GlobalGameData.faction_relations.get_relation(fac_3, fac_4)))
	print(str(GlobalGameData.faction_relations.get_relation(fac_5, fac_6)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
