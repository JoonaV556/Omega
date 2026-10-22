class_name SpaceChunk
extends Chunk

## System in this galaxy. may be null
var system: SpaceObject

## Which galaxy this chunk belongs to. may be null 
var galaxy: Galaxy

## dict where [object: SpaceObject, local position]
var objects: Dictionary[SpaceObject, Vector2]

var bodies_root: OrbitalBody

var primary_object_position: Vector2
