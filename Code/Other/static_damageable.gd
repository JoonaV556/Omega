# simple parent script for destoyable environment props. Mainly used for retrieving references to child nodes and avoiding using node.find() etc.
class_name StaticDamageable
extends StaticBody2D

@export var health: Health
