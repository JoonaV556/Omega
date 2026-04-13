class_name Task
extends Node # maybe change later on 

## If true, the behavior task is considered complete. Set true once desired goal is reached 
var completed: bool = false

func start():
    self.completed = false

func update():
    pass