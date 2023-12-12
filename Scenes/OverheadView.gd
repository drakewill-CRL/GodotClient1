extends Node2D

#This is the TIBO style "load multiple mapTiles, scroll them around to center the user'
#view. Create enough tiles to fill the map, add 1 to that, and then set them to load data

#TODO: may check this object's W/H instead of the viewports? Alter view size?
#or is that better served as a separate thing?

#TODO this should move around to keep the player's position in the very center of the screen.
#That probably requires another listener to shift the position of the node around a few pixels on 
#plusCode change.

@onready var camera : Camera2D = $Camera2D
var startX = 0
var startY = 0

func _unhandled_input(event):
	return #ignoring this for now.
	if event is InputEventScreenTouch and event.is_pressed() == true:
		print(event.position) #Screen coordinates. 0,0 is top left.
		get_viewport().set_input_as_handled()
		
		var size = get_viewport_rect().size
		#TODO: numbers here may need shifted later to match scroll offsets.
		#TODO: this is grabbing from anchor, needs to get tile relative to center offset.
		var innerX =  floor((int(event.position.x) - (size.x / 2)) / PraxisMapper.mapTileWidth) # - position.x
		var innerY =  floor((int(event.position.y) - (size.y / 2))  / PraxisMapper.mapTileHeight) #- position.y
		
		var subX =  int(event.position.x) % PraxisMapper.mapTileWidth # - position.x
		var subY =  int(event.position.y) % PraxisMapper.mapTileHeight #- position.y
		
		var innerNode = get_node("mapTile_" + str(innerX) + "_" + str(innerY))
		var tappedCode = innerNode.getTappedCode(subX, subY)
		
		

# Called when the node enters the scene tree for the first time.
func _ready():
	var mapTileScene = preload("res://PraxisMapper/Controls/MapTile.tscn")
	var size = get_viewport_rect().size
	print(size) # expected, 1080 and 1920, so pre-scaling viewport info.
	
	#godot default anchor is top-left. Does that require adjusting this logic to center?
	#PlusCode anchors are bottom-left, so there's a little work in mapping them together nicely.
	
	#5x7 tiles for a 1080p screen.
	var tilesX = ceil(size.x / PraxisMapper.mapTileWidth) + 1
	var tilesY = ceil(size.y / PraxisMapper.mapTileHeight) + 1
	
	if (int(tilesX) % 2 == 0):
		tilesX += 1
	if (int(tilesY) % 2 == 0):
		tilesY += 1
	
	startX = -size.x /2 + (PraxisMapper.mapTileWidth / 2) #(((tilesX - 1) * PraxisMapper.mapTileWidth) / -2)
	startY = -size.y /2 + (PraxisMapper.mapTileHeight / 2) #(((tilesY- 1) * PraxisMapper.mapTileHeight) / -2)
	
	#count:
	#I want the total grid to be big enough that there's 1/2 a tile extra on each side.
	#Plus it needs to be odd so the player can be perfectly centered.
	#:EX: if 3x3 tiles cover screen exactly, I need at least 5x5?
	
	#this way gets the tiles set up so the current tile is in the center
	for x in range(tilesX / -2, (tilesX /2) + 1):
		for y in range(tilesY / -2, (tilesY / 2) + 1):
	#this way would make all the math easier instead.
	#for x in range(0, tilesX):
		#for y in range(tilesY, 0, -1):
			var tile = mapTileScene.instantiate()
			tile.name = "mapTile_" + str(x) + "_" + str(y)
			add_child(tile)
			tile.xOffset = x
			tile.yOffset = y
			#again, easier math
			#tile.position.x = 320 * x
			#tile.position.y = (400 * tilesY) - (400 * y)
			#and centers-current-position.
			#tile.position.x = (x + (tilesX /2)) * 320
			#tile.position.y = size.y - (y + (tilesY /2)) * 400
			
			#this puts the center tile's top left corner at the top-left corner of the screen.
			tile.position.x = x * PraxisMapper.mapTileWidth + x + x
			tile.position.y = -y * PraxisMapper.mapTileHeight - y -y
			PraxisCore.plusCode_changed.connect(tile.OnPlusCodeChanged)
			tile.GetTile(PraxisMapper.currentPlusCode)
			
	camera.position.x = startX
	camera.position.y = startY
	
	PraxisCore.plusCode_changed.connect(CameraScroll)
	CameraScroll(PraxisMapper.currentPlusCode, "")
	
func _process(delta):
	#camera.position.x -= 1
	pass
	
func CameraScroll(currentPlusCode, previousPlusCode):
	#if (current.substr(0,8) == previous.substr(0,8)):
		#move camera to the correct position. 
		#May not need to check for Cell8 changes, since map tiles listen for that.
	print("scrolling camera to " + currentPlusCode)
	var currentXPos = currentPlusCode.substr(9,1)
	var xIndex = PlusCodes.CODE_ALPHABET_.find(currentXPos)
	var xShift = (PraxisMapper.mapTileWidth / 2) -  (PraxisMapper.mapTileWidth / 20) * xIndex
	#var prevXPos = previous.substr(10,1)
	var currentYPos = currentPlusCode.substr(8,1)
	var yIndex = PlusCodes.CODE_ALPHABET_.find(currentYPos)
	var yShift = (PraxisMapper.mapTileHeight / 2) - (PraxisMapper.mapTileHeight / 20) * yIndex
	#var prevYPos = previous.substr(9,1)
	
	print("current pos:" + currentXPos + "," + currentYPos)
	
	camera.position.x = startX - xShift
	camera.position.y = startY + yShift
