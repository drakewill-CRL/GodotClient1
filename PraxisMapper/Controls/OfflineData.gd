extends Node2D

@onready var request: PraxisEndpoints = $PraxisEndpoints

signal style_saved()
signal style_ready()
signal data_saved()
signal data_ready()
signal tiles_saved()
signal nametiles_saved()

var plusCode = ""
var style = "mapTiles"
var scaleVal = 1
var mapData

func GetAndProcessData(pluscode6, scaleSize, styleSet):
	plusCode = pluscode6
	scaleVal = scaleSize
	style = styleSet
	await GetStyle()
	#await GetData()
	await GetDataFromZip("OhioOffline.zip", pluscode6)
	await SaveTiles()
	await SaveNameTiles()
	
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
		$svc/SubViewport/nameMap.style = info
		styleData.close()
	style_ready.emit()

func SaveStyle(data):
	request.response_data.disconnect(SaveStyle)
	var text = data.get_string_from_utf8()
	var styleData = FileAccess.open("user://Styles/" + style + ".json", FileAccess.WRITE)
	if (styleData == null):
		print(FileAccess.get_open_error())
	
	styleData.store_string(text)
	styleData.close()
	
	var json = JSON.new()
	json.parse(text)
	var styleinfo = json.get_data()
	$svc/SubViewport/fullMap.style = styleinfo
	style_saved.emit()

func GetData():
	var locationData = FileAccess.open("user://Offline/" + plusCode + ".json", FileAccess.READ)
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
	request.response_data.disconnect(SaveData)
	var json = JSON.new()
	var stringData = data.get_string_from_utf8()
	json.parse(stringData)
	mapData = json.get_data()
	
	var savedData = FileAccess.open("user://Offline/" + plusCode + ".json", FileAccess.WRITE)
	savedData.store_string(stringData)
	savedData.close()
	data_saved.emit()
	
func GetDataFromZip(file, plusCode):
	var zipReader = ZIPReader.new()
	var err = zipReader.open("user://" + file) #Assumes this was written to the user partition, not resources.
	if (err != OK):
		return
		
	var code2 = plusCode.substr(0, 2)
	var code4 = plusCode.substr(2, 2)
	var rawdata := zipReader.read_file(code2 + "/" + code4 + "/" + plusCode + ".json")
	var realData = rawdata.get_string_from_utf8()
	var json = JSON.new()
	json.parse(realData)
	mapData = json.data
	data_ready.emit()

func SaveTiles():
	$svc/SubViewport/fullMap.visible = true
	$svc/SubViewport/nameMap.visible = false
	$svc/SubViewport/fullMap.DrawOfflineTile(mapData.entries["mapTiles"], scaleVal)
	await CreateTiles()
	
func SaveNameTiles():
	$svc/SubViewport/fullMap.visible = false
	$svc/SubViewport/fullMap.position.y = -100000
	$svc/SubViewport/nameMap.visible = true
	$svc/SubViewport/nameMap.DrawOfflineNameTile(mapData.entries["mapTiles"], scaleVal)
	await CreateNameTiles()
	
func SaveAdminNameTiles():
	$svc/SubViewport/fullMap.visible = false
	$svc/SubViewport/fullMap.position.y = -100000
	$svc/SubViewport/nameMap.visible = true
	$svc/SubViewport/nameMap.DrawOfflineNameTile(mapData.entries["adminBounds"], scaleVal)
	await CreateNameTiles()

func CreateTiles():
	var viewport = $svc/SubViewport
	var camera = $svc/SubViewport/subcam
	var scale = scaleVal
	
	camera.position = Vector2(0,0)
	viewport.size = Vector2i(320 * scale, 500 * scale) #This subviewport draws the Cell8 image.
	await RenderingServer.frame_post_draw
		
	for yChar in PlusCodes.CODE_ALPHABET_:
		#This kept complaining about can't - a Vector2 and an Int so I had to do this.
		#yPos -= (PlusCodes.CODE_ALPHABET_.find(yChar) * 20 * scale)
		camera.position.y -= (500 * scale)
		for xChar in PlusCodes.CODE_ALPHABET_:
			camera.position.x = (PlusCodes.CODE_ALPHABET_.find(xChar) * 320 * scale)
			await RenderingServer.frame_post_draw
			var img = viewport.get_texture().get_image() # Get rendered image
			img.save_png("user://MapTiles/" + plusCode + yChar + xChar + "-" + str(scale) + ".png") # Save to disk
			print("Saved tile " + plusCode + yChar + xChar)
	
	tiles_saved.emit()
	
func CreateNameTiles():
	var viewport = $svc/SubViewport
	var camera = $svc/SubViewport/subcam
	var scale = scaleVal

	camera.position = Vector2(0,0)
	viewport.size = Vector2i(320 * scale, 500 * scale) #This subviewport draws the Cell8 image.
	await RenderingServer.frame_post_draw
		
	for yChar in PlusCodes.CODE_ALPHABET_:
		#This kept complaining about can't - a Vector2 and an Int so I had to do this.
		#yPos -= (PlusCodes.CODE_ALPHABET_.find(yChar) * 20 * scale)
		camera.position.y -= (500 * scale)
		for xChar in PlusCodes.CODE_ALPHABET_:
			camera.position.x = (PlusCodes.CODE_ALPHABET_.find(xChar) * 320 * scale)
			await RenderingServer.frame_post_draw
			var img = viewport.get_texture().get_image() # Get rendered image
			img.save_png("user://NameTiles/" + plusCode + yChar + xChar + "-" + str(scale) + ".png") # Save to disk
			print("Saved nametile " + plusCode + yChar + xChar)
	
	nametiles_saved.emit()
