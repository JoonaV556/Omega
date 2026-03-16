extends CollisionShape2D

func safe_disable():
	call_deferred("set_disabled", true)
