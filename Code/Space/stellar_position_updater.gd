## Updates virtualized ship stellar position based on ship nodes 2D world movements
class_name StellarPositionUpdater2D
extends Node


var _position_tracker: VirtualStellarPositionTracker

var _ssc: SpaceShipController

var _last_pos: Vector2


func _ready() -> void:
	_initialize.call_deferred()


func _process(_delta: float) -> void:
	if !_position_tracker or !_ssc:
		return
	
	_position_tracker.move(_ssc.global_position - _last_pos)
	_last_pos = _ssc.global_position
	

func _initialize():
	_ssc = get_parent() as SpaceShipController

	if !_ssc:
		return

	var ship_virtual: SpaceShip = SpaceshipManager.get_ship(_ssc.ship_id)

	if !ship_virtual:
		return

	_position_tracker = ship_virtual.position_tracker

	_last_pos = _ssc.global_position
