extends Node2D

#This is already offline data, we need to load it from the current program's
#res://OfflineData folder.


signal style_saved()
signal style_ready()
signal data_saved()
signal data_ready()
signal tiles_saved()
#signal nametiles_saved()

var plusCode = ""
var style = "suggestedmini"
var scaleVal = 1
var mapData

func GetAndProcessData(pluscode6, styleSet):
	print("Triple-processing minimized data")
	plusCode = pluscode6
	scaleVal = 1
	style = styleSet
	await GetStyle()
	await GetDataFromZip(pluscode6)
	print("begin tile making for " + pluscode6)
	await CreateAllTiles()
	
func GetStyle():
	var styleData = FileAccess.open("res://PraxisMapper/Styles/" + style + ".json", FileAccess.READ)
	if (styleData == null):
		print("HEY DEV - go make and sa ve the style json here!")
	else:
		var json = JSON.new()
		json.parse(styleData.get_as_text())
		var info = json.get_data()
		$svc/SubViewport/fullMap.style = info
		$svc2/SubViewport/nameMap.style = info
		$svc4/SubViewport/terrainMap.style = info
		styleData.close()
		
	style_ready.emit()

func GetData():
	var locationData = FileAccess.open("user://Offline/" + plusCode + ".json", FileAccess.READ)
	if (locationData == null):
		print("HEY DEV - minOffline failed to get data.")
	else:
		var json = JSON.new()
		json.parse(locationData.get_as_text())
		mapData = json.get_data()
		locationData.close()
		
	data_ready.emit()

func GetDataFromZip(plusCode):
	var code2 = plusCode.substr(0, 2)
	var code4 = plusCode.substr(2, 2)
	var zipReader = ZIPReader.new()
	var err = zipReader.open("res://OfflineData/" + code2 + "/" + code2 + code4 + ".zip")
	if (err != OK):
		return
		
	var rawdata := zipReader.read_file(plusCode + ".json")
	var realData = rawdata.get_string_from_utf8()
	var json = JSON.new()
	json.parse(realData)
	mapData = json.data
	data_ready.emit()

func CreateAllTiles():
	#Gonna try and see if we can write 3 tiles at once.
	#Fullmap at 0, name map at 4k, bounds map at 8k. terrain at 12k
	#This is Cell6 data drawn with Cell10 pixels, so each image is 400x400
	#I don't need to subdivide these images any further.
	
	$svc/SubViewport/fullMap.position.y = 0
	$svc2/SubViewport/nameMap.position.y = 400
	#$svc3/SubViewport/boundsMap.position.y = 800
	$svc4/SubViewport/terrainMap.position.y = 1200
	
	$svc/SubViewport/fullMap.DrawOfflineTile(mapData.entries["suggestedmini"], scaleVal)
	$svc2/SubViewport/nameMap.DrawOfflineNameTile(mapData.entries["suggestedmini"], scaleVal)
	#$svc3/SubViewport/boundsMap.DrawOfflineBoundsTile(mapData.entries["adminBoundsFilled"], scaleVal)
	$svc4/SubViewport/terrainMap.DrawOfflineTerrainTile(mapData.entries["suggestedmini"], scaleVal)
	
	var viewport1 = $svc/SubViewport
	var viewport2 = $svc2/SubViewport
	#var viewport3 = $svc3/SubViewport
	var viewport4 = $svc4/SubViewport
	var camera1 = $svc/SubViewport/subcam
	var camera2 = $svc2/SubViewport/subcam
	#var camera3 = $svc3/SubViewport/subcam
	var camera4 = $svc4/SubViewport/subcam
	var scale = scaleVal
	
	camera1.position = Vector2(0,-400)
	camera2.position = Vector2(0,0)
	#camera3.position = Vector2(400,8000)
	camera4.position = Vector2(0,800)
	viewport1.size = Vector2i(400 * scale, 400 * scale)
	viewport2.size = Vector2i(400 * scale, 400 * scale)
	#viewport3.size = Vector2i(400 * scale, 400 * scale)
	viewport4.size = Vector2i(400 * scale, 400 * scale)
	await RenderingServer.frame_post_draw
	
	var img1 = viewport1.get_texture().get_image() # Get rendered image
	img1.save_png("user://MapTiles/" + plusCode + ".png") # Save to disk
	var img2 = viewport2.get_texture().get_image() # Get rendered image
	img2.save_png("user://NameTiles/" + plusCode + ".png") # Save to disk
	#var img3 = viewport3.get_texture().get_image() # Get rendered image
	#img3.save_png("user://BoundsTiles/" + plusCode + yChar + xChar + ".png") # Save to disk
	var img4 = viewport4.get_texture().get_image() # Get rendered image
	img4.save_png("user://TerrainTiles/" + plusCode + ".png") # Save to disk
	print("Saved minimized tile for " + plusCode)
	
	tiles_saved.emit()

func CreateTiles(folderName):
	var viewport = $svc/SubViewport
	var camera = $svc/SubViewport/subcam
	var scale = scaleVal
	
	camera.position = Vector2(0,0)
	viewport.size = Vector2i(400 * scale, 400 * scale) #This subviewport draws the Cell8 image.
	await RenderingServer.frame_post_draw
		
	for yChar in PlusCodes.CODE_ALPHABET_:
		#This kept complaining about can't - a Vector2 and an Int so I had to do this.
		#yPos -= (PlusCodes.CODE_ALPHABET_.find(yChar) * 20 * scale)
		camera.position.y -= (400 * scale)
		for xChar in PlusCodes.CODE_ALPHABET_:
			camera.position.x = (PlusCodes.CODE_ALPHABET_.find(xChar) * 400 * scale)
			await RenderingServer.frame_post_draw
			var img = viewport.get_texture().get_image() # Get rendered image
			img.save_png("user://" + folderName + "/" + plusCode + yChar + xChar + "-" + str(scale) + ".png") # Save to disk
			print("Saved tile " + plusCode + yChar + xChar)
	
	tiles_saved.emit()
