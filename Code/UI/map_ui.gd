class_name MapUI
extends Control


@export var galaxy_icon_texture : Texture

@export var galaxy_icon_scale : Vector2 = Vector2(1.0, 1.0)

@export var objects_root : Node2D

@export var object_info_label : Label

@export var selection_overlay_node : TextureRect


var current_layer : LAYER

var _galaxy_icons : Array[Sprite2D]

var _object_selector : Selector

var _map_objects : Dictionary[Sprite2D, StellarObject]


signal on_layer_changed(new_layer : String)


enum LAYER {
	Galaxies, 
	Systems,
	}


enum OBJECT_TYPE {
	Galaxy,
	StarSystem
}


var object_type_strings : Dictionary = {
	Galaxy: "Galaxy",
	StarSystem: "Star System",
}


func _ready() -> void:
	_object_selector = Selector.new(self)
	_object_selector.on_selected.connect(on_object_selected)
	_object_selector.register_unselector_control(self)
	_object_selector.on_unselected.connect(on_object_unselected)

	set_layer(LAYER.Galaxies)

	selection_overlay_node.hide()


func on_object_selected(new_selection : Node):
	if !new_selection is Sprite2D:
		return

	var selected_sprite = new_selection as Sprite2D

	if !selected_sprite:
		return

	# Update object info ui
	var selected_object : StellarObject = _map_objects[selected_sprite]

	var object_type_str : String = "unknown"

	if selected_object is Galaxy:
		object_type_str = object_type_strings[Galaxy]
	if selected_object is StarSystem:
		object_type_str = object_type_strings[StarSystem]
		
	
	print('Selected %s' % [new_selection.name])

	object_info_label.text = String(
		"Object Info
		\n\t name: %s
		\n\t type: %s" % [object_type_str, selected_object.name]
	)
	object_info_label.show()

	selection_overlay_node.show()
	selection_overlay_node.position = selected_sprite.position


func on_object_unselected():
	print('Unselected')
	object_info_label.hide()

	selection_overlay_node.hide()


func set_layer_int(new_layer : int):
	set_layer(new_layer as LAYER)


func set_layer(new_layer : LAYER):
	current_layer = new_layer
	on_layer_changed.emit(LAYER.keys()[current_layer])
	print('Map layer changed to %s' % [LAYER.keys()[current_layer]])


func draw_galaxies(galaxies : Array[Galaxy]):
	for gal in galaxies:
		var map_object_sprite : Sprite2D = Sprite2D.new()

		objects_root.add_child(map_object_sprite)

		map_object_sprite.z_as_relative = false
		map_object_sprite.name = String('map_object_%s' % [gal.name])
		map_object_sprite.position = gal.local_coords
		map_object_sprite.texture = galaxy_icon_texture
		map_object_sprite.scale = galaxy_icon_scale
		map_object_sprite.centered = true

		_galaxy_icons.append(map_object_sprite)

		_map_objects[map_object_sprite] = gal

		# Make map object selectable
		_object_selector.register_selectable_sprite2d(map_object_sprite)


func update_galaxy_icons_scale(new_scale):
	for icon in _galaxy_icons:
		icon.scale = scale
