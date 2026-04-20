class_name GESceneProxy
extends Node

signal gesp_on_bullet_landed(pos)

func _ready():
	GlobalEventBus.on_bullet_landed.connect(geb_on_bullet_land)

func geb_on_bullet_land(_pos):
	gesp_on_bullet_landed.emit(_pos)
