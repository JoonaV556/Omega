extends Button

func skip():
	Dialogic.end_timeline()
	print_debug("Skipped dialogue.")
