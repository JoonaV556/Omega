extends Node

@export var tmap: TileMapLayer

func _ready():
	generate.call_deferred()

func generate():
	#generate 
	var q = QuadTree.new()

	q.divide_recursive()

	q.divide_recursive(2)

	# draw on tilemap
	pass
