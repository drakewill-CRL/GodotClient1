extends Node2D

#This one loads up and displays a map tile.
#TODO declare components separately, start with static texture until image is loaded

#TODO: could allow these to update themselves 
@onready var request: HTTPRequest = $HTTPRequest
@onready var texRect: TextureRect = $TextureRect

#Possible improvements:
var currentTile = ''
var xOffset = 0
var yOffset = 0

#fires off a signal indicating the user tapped this tile, and what the target PlusCode they tapped is
signal user_tapped(plusCode) 

func getTappedCode(x, y):
	var cellsX = PraxisMapper.mapTileWidth / 20
	var cellsY = PraxisMapper.mapTileHeight / 20
		
	var tappedCell = PlusCodes.ShiftCode(currentTile + "22", x / cellsX, (400 - y) / cellsY )
	print(tappedCell)
	return tappedCell

#The function to detect user taps.
#TODO: this makes all mapTiles fire off the check on tap. Need to limit that to the tapped one
#maybe thats handled by the parent scene?
func _input_event(event):
	if event is InputEventScreenTouch and event.is_pressed() == true:
		
		#now work out which plusCode was tapped
		var innerX =  int(event.position.x) % PraxisMapper.mapTileWidth # - position.x
		var innerY =  int(event.position.y) % PraxisMapper.mapTileHeight #- position.y
		
		#innerX/Y should now be the pixel inside this control we tapped.
		#and this map tile is a Cell8, so we can work it out to a Cell11 accuracy
		var cellsX = PraxisMapper.mapTileWidth / 80
		var cellsY = PraxisMapper.mapTileHeight / 100
		
		var tappedCell = PlusCodes.ShiftCode(currentTile + "22", innerX / cellsX, innerY / cellsY )
		print(tappedCell)

func tile_called(result, responseCode, headers, body):
	print(responseCode)
	request.request_completed.disconnect(tile_called)
	if result != HTTPRequest.RESULT_SUCCESS:
		return "error"
	
	var image = Image.new()
	if (image.load_png_from_buffer(body) != OK):
		return "error2"
		
	var saved = image.save_png("user://MapTiles/" + currentTile + ".png")
	if (saved != OK):
		print("Not saved: " + str(saved))
	
	var texture = ImageTexture.create_from_image(image)
	texRect.texture = texture
	
func GetTile(plusCode):	
	if PraxisMapper.currentPlusCode.substr(0,8) == PraxisMapper.lastPlusCode.substr(0,8):
		return
	
	currentTile = plusCode.substr(0,8)
	
	if (xOffset != 0 or yOffset != 0): #ShiftCode does NOT add the +
		currentTile = PlusCodes.ShiftCode(currentTile, xOffset, yOffset)
	
	print(currentTile)
	var img = Image.new().load_from_file("user://MapTiles/" + currentTile + ".png")
	if (img != null):
		print("existing file found")
		texRect.texture = ImageTexture.create_from_image(img)
	else:
		print("loading tile from server")
		request.request_completed.connect(tile_called)
	
		var ok = request.request("http://192.168.50.74:5000/MapTile/Area/" + currentTile)
		if (ok != OK):
			print("maptile request not ok")
			pass
		
func OnPlusCodeChanged(current, previous):
	GetTile(current)

# Called when the node enters the scene tree for the first time.
func _ready():
	var noiseTex = NoiseTexture2D.new()
	noiseTex.width = PraxisMapper.mapTileWidth
	noiseTex.height = PraxisMapper.mapTileHeight
	noiseTex.noise = FastNoiseLite.new()
	texRect.texture = noiseTex

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
