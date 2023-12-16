extends Node2D

#This one loads up and displays a map tile.
#TODO declare components separately, start with static texture until image is loaded

@onready var request: GenericCall = $GenericCall
@onready var texRect: TextureRect = $TextureRect
@onready var timer: Timer = $Timer

var currentTile = ''
@export var xOffset = 0
@export var yOffset = 0
@export var autoRefresh = false
@export var autoRefreshSeconds = 60
@export var styleSet = 'mapTiles'
var tileGeneration = 0
var noiseTex : NoiseTexture2D

#fires off a signal indicating the user tapped this tile, and what the target PlusCode they tapped is
signal user_tapped(plusCode) 

func getTappedCode(x, y):
	var cellsX = PraxisMapper.mapTileWidth / 20
	var cellsY = PraxisMapper.mapTileHeight / 20
	#TODO: this needs adjusted to match the screen being centered?
	var tappedCell = PlusCodes.ShiftCode(currentTile + "22", x / cellsX, (400 - y) / cellsY )
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
		
func GetTileGeneration():
	#This will call the tile generation ID api to see if the one on the server is different from the
	#one on the device and if so, get the server's version.
	print("getting tile generation")
	request.response_data.connect(GenerationListener)
	var ok = request.GetTileGenerationID(currentTile, styleSet)
		
func GenerationListener(result):
	print("Generation listener got result")
	request.response_data.disconnect(GenerationListener)
	
	var currentGen = int(result.get_string_from_utf8())
	if (currentGen != tileGeneration):
		tileGeneration = currentGen
		LoadTile(currentTile)

func tile_called(result):
	print("tile called received body")
	request.response_data.disconnect(tile_called)
	
	var image = Image.new()
	if (image.load_png_from_buffer(result) != OK):
		return "error2"
		
	var saved = image.save_png("user://MapTiles/" + currentTile + "-" + styleSet + ".png")
	if (saved != OK):
		print("Not saved: " + str(saved))
	
	var texture = ImageTexture.create_from_image(image)
	texRect.texture = texture
	
func LoadTile(plusCode):
	#this loads the image for the plusCode given. GetTile shifts appropriately for offsets automatically.
	print('loading tile ' + plusCode)
	texRect.texture = noiseTex
	var img = Image.new().load_from_file("user://MapTiles/" + plusCode + "-" + styleSet + ".png")
	if (img != null):
		texRect.texture = ImageTexture.create_from_image(img)
	else:
		request.response_data.connect(tile_called)
	
		print("getting " + PraxisMapper.serverURL + "/MapTile/Area/" + plusCode + "/" + styleSet)
		request.DrawMapTile(plusCode, styleSet)
	
func GetTile(plusCode):	
	if PraxisMapper.currentPlusCode.substr(0,8) == PraxisMapper.lastPlusCode.substr(0,8):
		return
	
	currentTile = plusCode.substr(0,8)
	
	if (xOffset != 0 or yOffset != 0): #ShiftCode does NOT add the +
		currentTile = PlusCodes.ShiftCode(currentTile, xOffset, yOffset)
		
	LoadTile(currentTile)

func OnPlusCodeChanged(current, previous):
	GetTile(current)

# Called when the node enters the scene tree for the first time.
func _ready():
	#TODO: make NoiseTexture a proper node to reference multiple times?
	noiseTex = NoiseTexture2D.new()
	noiseTex.width = PraxisMapper.mapTileWidth
	noiseTex.height = PraxisMapper.mapTileHeight
	noiseTex.noise = FastNoiseLite.new()
	texRect.texture = noiseTex
	
	if (autoRefresh == true):
		timer.one_shot = false
		timer.autostart = true
		timer.start()
