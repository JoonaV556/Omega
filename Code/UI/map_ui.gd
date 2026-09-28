class_name MapUI
extends Control


@export var galaxy_icon_texture : Texture

@export var galaxy_icon_scale : Vector2 = Vector2(1.0, 1.0)

@export var objects_root : Node2D


var mode : MODE

var _galaxy_icons : Array[Sprite2D]

var _object_selector : Selector


signal on_mode_changed(new_mode : String)


enum MODE {
	Galaxy, 
	System
	}


func _ready() -> void:
	_object_selector = Selector.new()
	add_child(_object_selector)
	_object_selector.on_selected.connect(on_object_selected)


func on_object_selected(new_selection : Node):
	print('Selected %s' % [new_selection.name])


func set_mode_int(new_mode : int):
	set_mode(new_mode as MODE)


func set_mode(new_mode : MODE):
	mode = new_mode
	on_mode_changed.emit(MODE.keys()[mode])
	print('Map mode changed to %s' % [MODE.keys()[mode]])


func draw_galaxies(galaxies : Array[Galaxy]):
	for gal in galaxies:
		var map_object_sprite : Sprite2D = Sprite2D.new()

		objects_root.add_child(map_object_sprite)

		map_object_sprite.z_as_relative = false
		map_object_sprite.name = String('map_object_%s' % [gal.name])
		map_object_sprite.position = gal.local_coords
		map_object_sprite.texture = galaxy_icon_texture
		map_object_sprite.scale = galaxy_icon_scale

		_galaxy_icons.append(map_object_sprite)

		# Make map object selectable
		_object_selector.register_selectable_sprite2d(map_object_sprite)


func update_galaxy_icons_scale(new_scale):
	for icon in _galaxy_icons:
		icon.scale = scale
