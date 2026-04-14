extends Node
signal on_bullet_landed(global_position)

func _ready():
	# on_bullet_landed.connect(test_event)
	pass

func test_event(asd):
	print("the event works")
