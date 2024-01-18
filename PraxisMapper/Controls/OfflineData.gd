extends Node2D

@onready var request: PraxisEndpoints = $PraxisEndpoints

signal style_saved()
signal style_ready()
signal data_saved()
signal data_ready()
signal tiles_saved()

var plusCode = ""
var style = "mapTiles"
var scaleVal = 1
var mapData

func GetAndProcessData(pluscode6, scaleSize, styleSet):
	plusCode = pluscode6
	scaleVal = scaleSize
	style = styleSet
	GetStyle()
	GetData()
	
func GetStyle():
	var styleData = FileAccess.open("user://Styles/" + style + ".json", FileAccess.READ)
	if (styleData == null):
		request.response_data.connect(SaveStyle)
		request.OfflineStyle(style)
		await style_saved
	else:
		var json = JSON.new()
		json.parse(styleData.get_as_text())
		var info = json.get_data()
		$svc/SubViewport/fullMap.style = info
		styleData.close()
	style_ready.emit()

func SaveStyle(data):
	request.response_data.disconnect(SaveStyle)
	var text = data.get_string_from_utf8()
	var styleData = FileAccess.open("user://Styles/mapTiles.json", FileAccess.WRITE)
	styleData.store_string(text)
	styleData.close()
	
	var json = JSON.new()
	json.parse(text)
	var styleinfo = json.get_data()
	$svc/SubViewport/fullMap.style = styleinfo
	style_saved.emit()

func GetData():
	var locationData = FileAccess.open_compressed("user://Offline/" + plusCode + ".jsonzip", FileAccess.READ)
	if (locationData == null):
		request.response_data.connect(SaveData)
		request.OfflineV2(plusCode)
		await data_saved
	else:
		var json = JSON.new()
		json.parse(locationData.get_as_text())
		mapData = json.get_data()
		locationData.close()
		
	data_ready.emit()

func SaveData(data):
	var json = JSON.new()
	var stringData = data.get_string_from_utf8()
	json.parse(stringData)
	mapData = json.get_data()
	
	var savedData = FileAccess.open_compressed("user://Offline/" + plusCode + ".jsonzip", FileAccess.WRITE)
	savedData.store_string(stringData)
	savedData.close()
	data_saved.emit()

func SaveTiles():
	$svc/SubViewport/fullMap.DrawOfflineTile(mapData.entries, scaleVal)
	CreateTiles()

func CreateTiles():
	var viewport = $svc/SubViewport
	var camera = $svc/SubViewport/subcam
	var scale = scaleVal
	
	camera.position.x = 0
	viewport.size = Vector2i(80 * scale, 100 * scale) #This subviewport draws the Cell8 image.
	await RenderingServer.frame_post_draw
		
	for yChar in PlusCodes.CODE_ALPHABET_:
		#This kept complaining about can't - a Vector2 and an Int so I had to do this.
		#yPos -= (PlusCodes.CODE_ALPHABET_.find(yChar) * 20 * scale)
		camera.position.y -= (100 * scale)
		for xChar in PlusCodes.CODE_ALPHABET_:
			camera.position.x = (PlusCodes.CODE_ALPHABET_.find(xChar) * 80 * scale)
			await RenderingServer.frame_post_draw
			var img = viewport.get_texture().get_image() # Get rendered image
			img.save_png("user://MapTiles/" + plusCode + yChar + xChar + "-" + str(scale) + ".png") # Save to disk
	
	tiles_saved.emit()
