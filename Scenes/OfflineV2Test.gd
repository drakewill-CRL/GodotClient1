extends Node2D

@onready var request: PraxisEndpoints = $PraxisEndpoints

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var styleData = FileAccess.open("user://mapTiles.json", FileAccess.READ)
	if (styleData == null):
		request.response_data.connect(saveStyle)
		request.OfflineStyle("mapTiles")
		await request.response_data
	else:
		var json = JSON.new()
		json.parse(styleData.get_as_text())
		var info = json.get_data()
		$svc/SubViewport/drawer.mapTiles = info	

	request.response_data.connect(call_done)
	request.OfflineV2("86HWGG")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func first_process(delta):
	if Input.is_action_pressed("ui_left"):
		$Camera2D.position.x -= 1
	if Input.is_action_pressed("ui_right"):
		$Camera2D.position.x += 1
	if Input.is_action_pressed("ui_up"):
		$Camera2D.position.y -= 1
	if Input.is_action_pressed("ui_down"):
		$Camera2D.position.y += 1
		
func _process(delta):
	if Input.is_action_pressed("ui_left"):
		$svc/SubViewport/subcam.position.x -= 1
	if Input.is_action_pressed("ui_right"):
		$svc/SubViewport/subcam.position.x += 1
	if Input.is_action_pressed("ui_up"):
		$svc/SubViewport/subcam.position.y -= 1
	if Input.is_action_pressed("ui_down"):
		$svc/SubViewport/subcam.position.y += 1
	pass
	
func saveStyle(data):
	request.response_data.disconnect(saveStyle)
	var text = data.get_string_from_utf8()
	var style = FileAccess.open("user://mapTiles.json", FileAccess.WRITE)
	style.store_string(text)
	style.close()
	
	var json = JSON.new()
	json.parse(text)
	var info = json.get_data()
	$svc/SubViewport/drawer.mapTiles = info	 #drawer as a verb, not a noun.

func call_done(data):
	print("Data complete!")
	var json = JSON.new()
	var stringData = data.get_string_from_utf8()
	json.parse(stringData)
	var info = json.get_data()
	#print(info)
	
	var ogData = FileAccess.open_compressed("user://86HWGG.jsonzip", FileAccess.WRITE)
	ogData.store_string(stringData)
	ogData.close()
	
	var scale = 3
	$svc/SubViewport/drawer.DrawOfflineTile(info.entries, scale)
	RenderToFiles("86HWGG", scale)

func RenderToFiles(plusCode, scale):
	#TODO: add a new Viewport node with a Camera2D to pan around and save stuff.
	
	#var vt = ViewportTexture.new()
	#vt.size = Vector2i(80 * scale, 100 * scale) #This subviewport draws the Cell8 image.
	#add_child(vt)
	#var svc = SubViewportContainer.new()
	#svc.size = Vector2i(80 * scale, 100 * scale) #This subviewport draws the Cell8 image.
	#add_child(svc)
	var viewport = $svc/SubViewport
	#var sv = SubViewport.new()
	#sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS #TODO may not be the right property, or necessary?
	#add_child(sv)
	#svc.add_child(sv)
	var camera = $svc/SubViewport/subcam
	
	viewport.add_child(camera)
	camera.position.x = 0
	viewport.size = Vector2i(80 * scale, 100 * scale) #This subviewport draws the Cell8 image.
	#camera.make_current()
	await RenderingServer.frame_post_draw
	#TODO: sort out correct properties for these nodes.
	#TODO: confirm I dont need the sv to be attached to a container or texture.
	#sv.size = Vector2i(80 * scale, 100 * scale) #This subviewport draws the Cell8 image.
	#TODO: see if this will save the whole image if I set the size to 3200x4000
	
	#TODO: foreach cell8 in the area given, move the camera.  This assumed this plusCode is a Cell6 area.
	for yChar in PlusCodes.CODE_ALPHABET_:
		#This kept complaining about can't - a Vector2 and an Int so I had to do this.
		#yPos -= (PlusCodes.CODE_ALPHABET_.find(yChar) * 20 * scale)
		camera.position.y -= (100 * scale)
		for xChar in PlusCodes.CODE_ALPHABET_:
			camera.position.x = (PlusCodes.CODE_ALPHABET_.find(xChar) * 80 * scale)
			await RenderingServer.frame_post_draw
			#TODO: Save image to file.
			var img = viewport.get_texture().get_image() # Get rendered image
			img.save_png("user://" + plusCode + yChar + xChar + "-" + str(scale) + ".png") # Save to disk
			#print("saved image " + plusCode + yChar + xChar)
			
	#Bonus fun attempt, and it works if the scale value is small enough:
	#viewport.size = Vector2i(80 * 20 * scale, 100 * 20 * scale) #This subviewport draws the Cell8 image.
	#camera.position.x = 0
	#camera.position.y = 100 * 20 * scale * -1
	#await RenderingServer.frame_post_draw
	#var texMax = viewport.get_texture() 
	#await get_tree().create_timer(2).timeout
	#var imgMax = texMax.get_image() # Get rendered image
	#await get_tree().create_timer(2).timeout
	#imgMax.save_png("user://" + plusCode + ".png") # Save to disk
	#print("saved image " + plusCode)
	
