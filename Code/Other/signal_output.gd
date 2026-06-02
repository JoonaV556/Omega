class_name SignalOutput
extends Node

signal on_triggered

func trigger():
    on_triggered.emit()