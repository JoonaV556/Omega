class_name Level
extends Node2D

@export var player_start_position: Vector2 = Vector2(0.0, 0.0)
@export var nav_tilemap: TileMapLayer

func load(_player: Node2D, _camera: Node2D):
	# place player and camera in a suitable location
	_player.reparent(self)
	_camera.reparent(self)
	_player.set_position(player_start_position)
	_camera.set_position(player_start_position)
