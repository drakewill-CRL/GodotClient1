extends Control

#This one loads up and displays a map tile.
#TODO declare components separately, start with static texture until image is loaded

func tile_called(result, responseCode, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		return "error"
	
	var image = Image.new()
	if (image.load_png_from_buffer(body) != OK):
		return "error2"
	
	var texture = ImageTexture.create_from_image(image)
	var texture_rect = TextureRect.new()
	add_child(texture_rect)
	texture_rect.texture = texture
	
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(tile_called)
	
	var ok = request.request("http://192.168.50.74:5000/MapTile/Area/86HWGG")
	if (ok != OK):
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
