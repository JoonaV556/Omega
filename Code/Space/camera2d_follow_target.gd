class_name Camera2DFollowTarget
extends Node

@export var target : Node2D

var _cam : Camera2D


func _ready() -> void:
    _cam = get_parent() as Camera2D


func _process(delta: float) -> void:
    _cam.global_position = target.global_position