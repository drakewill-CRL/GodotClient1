extends Node2D

@onready var request: PraxisEndpoints = $PraxisEndpoints

signal style_saved()
signal style_ready()
signal data_saved()
signal data_ready()
signal tiles_saved()
#signal nametiles_saved()

var plusCode = ""
var style = "mapTiles"
var scaleVal = 1
var mapData

func GetAndProcessData(pluscode6, scaleSize, styleSet):
	print("Triple-processing data")
	plusCode = pluscode6
	scaleVal = scaleSize
	style = styleSet
	await GetStyle()
	#await GetData()
	await GetDataFromZip("OhioOffline.zip", pluscode6)
	#await SaveTiles()
	#await SaveNameTiles()
	print("being tile making")
	await CreateAllTiles()
	
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
		$svc2/SubViewport/nameMap.style = info
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
	$svc/SubViewport/boundsMap.visible = false
	$svc/SubViewport/fullMap.DrawOfflineTile(mapData.entries["mapTiles"], scaleVal)
	await CreateTiles("MapTiles")
	
func SaveNameTiles():
	$svc/SubViewport/fullMap.visible = false
	$svc/SubViewport/fullMap.position.y = -100000
	$svc/SubViewport/boundsMap.visible = false
	$svc/SubViewport/boundsMap.position.y = -100000
	$svc/SubViewport/nameMap.visible = true
	$svc/SubViewport/nameMap.DrawOfflineNameTile(mapData.entries["mapTiles"], scaleVal)
	await CreateTiles("NameTiles")
	
func SaveAdminNameTiles():
	$svc/SubViewport/fullMap.visible = false
	$svc/SubViewport/fullMap.position.y = -100000
	$svc/SubViewport/nameMap.visible = false
	$svc/SubViewport/nameMap.position.y = -100000
	$svc/SubViewport/boundsMap.visible = true
	$svc/SubViewport/boundsMap.position.y = 0
	$svc/SubViewport/nameMap.DrawOfflineNameTile(mapData.entries["adminBoundsFilled"], scaleVal)
	await CreateTiles("BoundsTiles")
	
func CreateAllTiles():
	#Gonna try and see if we can write 3 tiles at once.
	#Fullmap at 0, name map at 40k, bounds map at 80k
	$svc/SubViewport/fullMap.position.y = 0
	$svc2/SubViewport/nameMap.position.y = 40000
	$svc3/SubViewport/boundsMap.position.y = 80000
	
	$svc/SubViewport/fullMap.DrawOfflineTile(mapData.entries["mapTiles"], scaleVal)
	$svc2/SubViewport/nameMap.DrawOfflineNameTile(mapData.entries["mapTiles"], scaleVal)
	$svc3/SubViewport/boundsMap.DrawOfflineBoundsTile(mapData.entries["adminBoundsFilled"], scaleVal)
	
	var viewport1 = $svc/SubViewport
	var viewport2 = $svc2/SubViewport
	var viewport3 = $svc3/SubViewport
	var camera1 = $svc/SubViewport/subcam
	var camera2 = $svc2/SubViewport/subcam
	var camera3 = $svc3/SubViewport/subcam
	var scale = scaleVal
	
	camera1.position = Vector2(0,0)
	camera2.position = Vector2(0,40000)
	camera3.position = Vector2(0,80000)
	viewport1.size = Vector2i(320 * scale, 500 * scale)
	viewport2.size = Vector2i(320 * scale, 500 * scale)
	viewport3.size = Vector2i(320 * scale, 500 * scale)
	await RenderingServer.frame_post_draw
		
	for yChar in PlusCodes.CODE_ALPHABET_:
		#This kept complaining about can't - a Vector2 and an Int so I had to do this.
		#yPos -= (PlusCodes.CODE_ALPHABET_.find(yChar) * 20 * scale)
		camera1.position.y -= (500 * scale)
		camera2.position.y -= (500 * scale)
		camera3.position.y -= (500 * scale)
		for xChar in PlusCodes.CODE_ALPHABET_:
			camera1.position.x = (PlusCodes.CODE_ALPHABET_.find(xChar) * 320 * scale)
			camera2.position.x = (PlusCodes.CODE_ALPHABET_.find(xChar) * 320 * scale)
			camera3.position.x = (PlusCodes.CODE_ALPHABET_.find(xChar) * 320 * scale)
			await RenderingServer.frame_post_draw
			var img1 = viewport1.get_texture().get_image() # Get rendered image
			img1.save_png("user://MapTiles/" + plusCode + yChar + xChar + "-" + str(scale) + ".png") # Save to disk
			var img2 = viewport2.get_texture().get_image() # Get rendered image
			img2.save_png("user://NameTiles/" + plusCode + yChar + xChar + "-" + str(scale) + ".png") # Save to disk
			var img3 = viewport3.get_texture().get_image() # Get rendered image
			img3.save_png("user://BoundsTiles/" + plusCode + yChar + xChar + "-" + str(scale) + ".png") # Save to disk
			print("Saved tiles for " + plusCode + yChar + xChar)
	
	tiles_saved.emit()

func CreateTiles(folderName):
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
			img.save_png("user://" + folderName + "/" + plusCode + yChar + xChar + "-" + str(scale) + ".png") # Save to disk
			print("Saved tile " + plusCode + yChar + xChar)
	
	tiles_saved.emit()
