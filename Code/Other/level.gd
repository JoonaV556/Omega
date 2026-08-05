class_name Level
extends Node2D

@export var player_start_position: Node2D
@export var nav_tilemap: TileMapLayer
@export var transitions: Array[LevelTransition]
@export var unique_name: StringName = "level_unnamed"

func get_transition_by_name(_name: StringName) -> LevelTransition:
    for trs in transitions:
        if trs.transition_name == _name:
            return trs
    return null

func get_transition_by_idx(idx: int) -> LevelTransition:
    return transitions[idx]