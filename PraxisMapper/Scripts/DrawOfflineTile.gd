extends Node2D

#This is for drawing map tiles directly in the client from Offline/V2 data

var theseentries = null
var thisscale = 1

#NOTE: drawOps are drawn in order, so the earlier one has the higher LayerId in PraxisMapper style language.
#the value/id/order is the MatchOrder for the style in PraxisMapper server


#TODO: set this to use Styles again, and let styles be set from the outside.
var styles = {}
static var mapTiles;


func DrawOfflineTile(entries, scale):
	theseentries = entries
	thisscale = scale
	queue_redraw()


func _draw():
	if theseentries == null:
		return
	
	#TODO get scale and image size here.
	#TODO: determine background color for image and fill that first. Depends on style.
	#for dev testing, this is the default x1 scale for a Cell8 image
	var scale = thisscale
	var width = 80 * 20 #= 1600
	var height = 100  * 20 #= 2000
	#REMEMBER: PlusCode origin is at the BOTTOM-left, these draw calls use the TOP left.
	#This should do the same invert drawing that PraxisMapper does server-side.
	draw_set_transform(Vector2(0,0), 0, Vector2(1,-1))
	
	#TODO jamming in a background drawing bit here
	var bgCoords = PackedVector2Array()
	bgCoords.append(Vector2(0,0))
	bgCoords.append(Vector2(width * scale,0))
	bgCoords.append(Vector2(width * scale,height * scale))
	bgCoords.append(Vector2(0,height * scale))
	bgCoords.append(Vector2(0,0))
	draw_colored_polygon(bgCoords, mapTiles["9999"].drawOps[0].color) 
	
	#entries has a big list of coord sets as strings
	for entry in theseentries:
		#TODO get style rule color and size for drawing here
		#TODO: loop here for each style draw rule entry.
		
		var thisStyle = mapTiles[str(entry.tid)]
		var styleColor = Color.MEDIUM_SPRING_GREEN
		var lineSize = 1.0 * scale
		
		#entry.p is a string of coords separated by a pipe
		#EX: 0,0|20,0|20,20|20,0|0,0 is a basic square.
		var coords = entry.p.split("|", false)
		var polyCoords = PackedVector2Array()
		for i in coords.size():
			var point = coords[i].split(",")
			var workVector = Vector2(int(point[0]) * scale, int(point[1]) * scale)
			polyCoords.append(workVector)
		
		for s in thisStyle.drawOps:
			if (entry.gt == 1):
				#this is just a circle for single points, size is roughly a Cell10
				#4.5 looks good for POIs, but bad for Trees, which there are quite a few of.
				#trees are size 0.2, so I should probably make other elements larger?
				#MOST of them shouldn't be points, but lines shouldn't be a Cell10 wide either.
				draw_circle(polyCoords[0], s.sizePx * 2.0 * scale, s.color)
			elif (entry.gt == 2):
				#This is significantly faster than calling draw_line for each of these.
				draw_polyline(polyCoords, s.color, s.sizePx * scale)
			elif entry.gt == 3:
				#A single color, which is what I generally use. TODO: decide how the texture2d part should work.
				draw_colored_polygon(polyCoords, s.color) 
	print("Drawing done")
	#RenderToFiles("86HWGG", scale)

func RenderToFiles(plusCode, scale):
	#TODO: add a new Viewport node with a Camera2D to pan around and save stuff.
	
	#var vt = ViewportTexture.new()
	#vt.size = Vector2i(80 * scale, 100 * scale) #This subviewport draws the Cell8 image.
	#add_child(vt)
	#var svc = SubViewportContainer.new()
	#svc.size = Vector2i(80 * scale, 100 * scale) #This subviewport draws the Cell8 image.
	#add_child(svc)
	var viewport = $svc/SubViewport
	viewport.size = Vector2i(80 * scale, 100 * scale) #This subviewport draws the Cell8 image.
	viewport.size_2d_override = Vector2i(80 * scale, 100 * scale) #This subviewport draws the Cell8 image.
	#var sv = SubViewport.new()
	#sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS #TODO may not be the right property, or necessary?
	#add_child(sv)
	#svc.add_child(sv)
	var camera = $svc/SubViewport/Camera2D
	
	viewport.add_child(camera)
	viewport.size = Vector2i(80 * scale, 100 * scale) #This subviewport draws the Cell8 image.
	camera.make_current()
	
	#TODO: sort out correct properties for these nodes.
	#TODO: confirm I dont need the sv to be attached to a container or texture.
	#sv.size = Vector2i(80 * scale, 100 * scale) #This subviewport draws the Cell8 image.
	#TODO: see if this will save the whole image if I set the size to 3200x4000
	
	camera.position.y = 4000
	#TODO: foreach cell8 in the area given, move the camera.  This assumed this plusCode is a Cell6 area.
	for yChar in PlusCodes.CODE_ALPHABET_:
		#This kept complaining about can't - a Vector2 and an Int so I had to do this.
		#yPos -= (PlusCodes.CODE_ALPHABET_.find(yChar) * 20 * scale)
		camera.position.y -= (100 * scale)
		for xChar in PlusCodes.CODE_ALPHABET_:
			#await RenderingServer.frame_post_draw
			camera.position.x = PlusCodes.CODE_ALPHABET_.find(xChar) * 20 * scale
			#TODO: Save image to file.
			var img = viewport.get_texture().get_image() # Get rendered image
			img.save_png("user://" + plusCode + yChar + xChar + ".png") # Save to disk
			print("saved image " + plusCode + yChar + xChar)
