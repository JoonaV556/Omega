extends Node
signal on_bullet_landed(global_position)
signal on_melee_attack(pos: Vector2)

func _ready():
	# on_bullet_landed.connect(test_event)
	pass

func test_event(asd):
	print("the event works")
