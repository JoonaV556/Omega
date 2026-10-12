class_name SpaceChunk
extends Chunk

## System in this galaxy. may be null
var system: StellarObject

## Which galaxy this chunk belongs to. may be null 
var galaxy: Galaxy

## dict where [object: StellarObject, ]
var stellar_objects: Dictionary[StellarObject, Vector2]
