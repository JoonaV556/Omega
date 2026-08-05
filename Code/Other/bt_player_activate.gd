extends BTPlayer

func activate():
	set_scene_root_hint(get_tree().current_scene)
	self.set_active(true)
