extends CollisionShape2D

func safe_disable():
	call_deferred("set_disabled", true)

func safe_enable():
	call_deferred("set_disabled", false)
