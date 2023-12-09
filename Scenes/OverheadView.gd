extends Node2D

#This is the TIBO style "load multiple mapTiles, scroll them around to center the user'
#view. Create enough tiles to fill the map, add 1 to that, and then set them to load data

#TODO: may check this object's W/H instead of the viewports? Alter view size?
#or is that better served as a separate thing?

#TODO this should move around to keep the player's position in the very center of the screen.
#That probably requires another listener to shift the position of the node around a few pixels on 
#plusCode change.

# Called when the node enters the scene tree for the first time.
func _ready():
	var mapTileScene = preload("res://PraxisMapper/Controls/MapTile.tscn")
	var size = get_viewport_rect().size
	print(size) # expected, 1080 and 1920, so pre-scaling viewport info.
	
	var tilesX = ceil(size.x / PraxisMapper.mapTileWidth)
	var tilesY = ceil(size.y / PraxisMapper.mapTileHeight)
	
	#count:
	#I want the total grid to be big enough that there's 1/2 a tile extra on each side.
	#Plus it needs to be odd so the player can be perfectly centered.
	#:EX: if 3x3 tiles cover screen exactly, I need at least 5x5?
	
	for x in range(tilesX / -2, tilesX /2):
		for y in range(tilesY / 2, tilesY / -2, -1):
			var tile = mapTileScene.instantiate()
			add_child(tile)
			tile.xOffset = x
			tile.yOffset = y
			tile.position.x = (x + (tilesX /2)) * 320
			tile.position.y = size.y - (y + (tilesY /2)) * 400
			PraxisCore.plusCode_changed.connect(tile.OnPlusCodeChanged)
			print(PraxisMapper.currentPlusCode)
			tile.GetTile(PraxisMapper.currentPlusCode)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
