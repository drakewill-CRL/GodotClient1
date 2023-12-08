extends Node2D

#This one loads up and displays a map tile.
#TODO declare components separately, start with static texture until image is loaded

#TODO: could allow these to update themselves 
@onready var request: HTTPRequest = $HTTPRequest
@onready var texRect: TextureRect = $TextureRect

#Possible improvements:
#Offsets, so this can draw a map tile X cells away in whichever direction from currentPlusCode
#automatic updates directly in the MapTile using signals. 
var currentTile = ''

func tile_called(result, responseCode, headers, body):
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
	currentTile = plusCode
	
	var img = Image.new().load_from_file("user://MapTiles/" + plusCode + ".png")
	if (img != null):
		print("existing file found")
		texRect.texture = ImageTexture.create_from_image(img)
	else:
		print("loading tile from server")
		request.request_completed.connect(tile_called)
	
		var ok = request.request("http://192.168.50.74:5000/MapTile/Area/" + plusCode)
		if (ok != OK):
			#TODO error state.
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
