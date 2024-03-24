extends Node2D
class_name OfflineDataV3

#This is the refined version of drawing offline data. This will display status to
#the user on-screen (with toggle to display or not), use toggles to determine which 
#tiles are drawn, and indicate via on-screen banner what the current status is on image
#drawing progress (drawing tile, saving tiles by code, etc)
#This will also assume the data is already present for now, and skip downloading it from
#a server.

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

@export var makeMapTile = true
@export var makeTerrainTile = true
@export var makeNameTile = true
@export var makeBoundsTile = true

func GetAndProcessData(pluscode6):
	$Banner.visible = true
	$Banner/lblStatus.text = "Preparing to draw...."
	print("V3 processing data")
	plusCode = pluscode6
	scaleVal = 1
	style = "mapTiles"
	await RenderingServer.frame_post_draw
	await SetStyleData()
	await GetDataFromZip(pluscode6)
	print("being tile making")
	await CreateAllTiles()
	
	$Banner/lblStatus.text = "Tiles Drawn for " + pluscode6
	await get_tree().create_timer(2).timeout
	#TODO: Tween this to fade
	$Banner.visible = false
	
func SetStyleData():
	var styleData = FileAccess.open("res://PraxisMapper/Styles/mapTiles.json", FileAccess.READ)
	var json = JSON.new()
	json.parse(styleData.get_as_text())
	var info = json.get_data()
	$svc/SubViewport/fullMap.style = info
	$svc2/SubViewport/nameMap.style = info
	$svc4/SubViewport/terrainMap.style = info
	styleData.close()
	style_ready.emit()

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
	#Fullmap at 0, name map at 40k, bounds map at 80k
	print("CreateAllTilesCalled")
	$svc/SubViewport/fullMap.position.y = 0
	$svc2/SubViewport/nameMap.position.y = 40000
	$svc3/SubViewport/boundsMap.position.y = 80000
	$svc4/SubViewport/terrainMap.position.y = 120000
	
	$Banner/lblStatus.text = "Drawing " + plusCode + "..."
	if makeMapTile == true:
		print("drawing map")
		await $svc/SubViewport/fullMap.DrawOfflineTile(mapData.entries["mapTiles"], scaleVal)
	if makeNameTile == true:
		print("drawing name")
		await $svc2/SubViewport/nameMap.DrawOfflineNameTile(mapData.entries["mapTiles"], scaleVal)
	if makeBoundsTile == true:
		print("drawing bounds")
		await $svc3/SubViewport/boundsMap.DrawOfflineBoundsTile(mapData.entries["adminBoundsFilled"], scaleVal)
	if makeTerrainTile == true:
		print("drawing terrain")
		await $svc4/SubViewport/terrainMap.DrawOfflineTerrainTile(mapData.entries["mapTiles"], scaleVal)
	
	var viewport1 = $svc/SubViewport
	var viewport2 = $svc2/SubViewport
	var viewport3 = $svc3/SubViewport
	var viewport4 = $svc4/SubViewport
	var camera1 = $svc/SubViewport/subcam
	var camera2 = $svc2/SubViewport/subcam
	var camera3 = $svc3/SubViewport/subcam
	var camera4 = $svc4/SubViewport/subcam
	var scale = scaleVal
	
	camera1.position = Vector2(0,0)
	camera2.position = Vector2(0,40000)
	camera3.position = Vector2(0,80000)
	camera4.position = Vector2(0,120000)
	viewport1.size = Vector2i(320 * scale, 500 * scale)
	viewport2.size = Vector2i(320 * scale, 500 * scale)
	viewport3.size = Vector2i(320 * scale, 500 * scale)
	viewport4.size = Vector2i(320 * scale, 500 * scale)
	await RenderingServer.frame_post_draw
		
	for yChar in PlusCodes.CODE_ALPHABET_:
		#This kept complaining about can't - a Vector2 and an Int so I had to do this.
		#yPos -= (PlusCodes.CODE_ALPHABET_.find(yChar) * 20 * scale)
		camera1.position.y -= (500 * scale)
		camera2.position.y -= (500 * scale)
		camera3.position.y -= (500 * scale)
		camera4.position.y -= (500 * scale)
			
		for xChar in PlusCodes.CODE_ALPHABET_:
			camera1.position.x = (PlusCodes.CODE_ALPHABET_.find(xChar) * 320 * scale)
			camera2.position.x = (PlusCodes.CODE_ALPHABET_.find(xChar) * 320 * scale)
			camera3.position.x = (PlusCodes.CODE_ALPHABET_.find(xChar) * 320 * scale)
			camera4.position.x = (PlusCodes.CODE_ALPHABET_.find(xChar) * 320 * scale)
			await RenderingServer.frame_post_draw
			if makeMapTile == true:
				var img1 = viewport1.get_texture().get_image() # Get rendered image
				img1.save_png("user://MapTiles/" + plusCode + yChar + xChar + "-" + str(scale) + ".png") # Save to disk
			if makeNameTile == true:
				var img2 = viewport2.get_texture().get_image() # Get rendered image
				img2.save_png("user://NameTiles/" + plusCode + yChar + xChar + "-" + str(scale) + ".png") # Save to disk
			if makeBoundsTile == true:
				var img3 = viewport3.get_texture().get_image() # Get rendered image
				img3.save_png("user://BoundsTiles/" + plusCode + yChar + xChar + "-" + str(scale) + ".png") # Save to disk
			if makeTerrainTile == true:
				var img4 = viewport4.get_texture().get_image() # Get rendered image
				img4.save_png("user://TerrainTiles/" + plusCode + yChar + xChar + "-" + str(scale) + ".png") # Save to disk
			print("Saved tiles for " + plusCode + yChar + xChar)
			$Banner/lblStatus.text = "Saved Tiles for " + plusCode + yChar + xChar
	
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
