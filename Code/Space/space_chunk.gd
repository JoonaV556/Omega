class_name SpaceChunk
extends Chunk

## System in this galaxy. may be null
var system: SpaceObject

## Which galaxy this chunk belongs to. may be null 
var galaxy: Galaxy

## dict where [object: SpaceObject, ]
var objects: Dictionary[SpaceObject, Vector2]
