extends Node2D

#This is the TIBO style "load multiple mapTiles, scroll them around to center the user'
#view. Create enough tiles to fill the map, add 1 to that, and then set them to load data

#TODO: may check this object's W/H instead of the viewports? Alter view size?
#or is that better served as a separate thing?

# Called when the node enters the scene tree for the first time.
func _ready():
	var size = get_viewport_rect().size
	print(size) # expected, 1080 and 1920, so pre-scaling viewport info.
	
	var tilesX = size.x / PraxisMapper.mapTileWidth
	var tilesY = size.y / PraxisMapper.mapTileHeight
	
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
