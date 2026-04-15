class_name Task
extends Node # maybe change later on 

signal on_complete

## If true, the behavior task is considered complete. Set true once desired goal is reached 
var completed: bool = false

func start():
    self.completed = false

func complete():
    self.completed = true
    on_complete.emit()

func update():
    pass