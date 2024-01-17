extends Node2D

#This is for drawing map tiles directly in the client from Offline/V2 data

var theseentries = null

#NOTE: drawOps are drawn in order, so the earlier one has the higher LayerId in PraxisMapper style language.
#the value/id/order is the MatchOrder for the style in PraxisMapper server

#TODO: styles should probably be a dictionary of style rules.
#TODO: I may need to add an 'Order' value to drawOps so the client can correctly draw layers.
static var styles = {
	"0" = {drawOps = [{color = Color.from_string("f2eef9", Color.MAGENTA), sizePx = 1.0}]}, #bg
	"10" = {drawOps = [{color = Color.from_string("8f8f8f", Color.MAGENTA), sizePx = 3.0}, {color = "ffffff", sizePx = 1.0}]}, #tertiary
	"20" = {drawOps = [{color = Color.from_string("ffffe5", Color.MAGENTA), sizePx = 1.0}]}, #university
	"30" = {drawOps = [{color = Color.from_string("FFD4CE", Color.MAGENTA), sizePx = 1.0}]}, #retail
	"35" = {drawOps = [{color = Color.from_string("3B3B3B", Color.MAGENTA), sizePx = 1.0}]}, #artsCulture
};


static var mapTiles;


func DrawOfflineTile(entries):
	theseentries = entries
	queue_redraw()


func _draw():
	if theseentries == null:
		return
	
	#TODO get scale and image size here.
	#TODO: determine background color for image and fill that first. Depends on style.
	#for dev testing, this is the default x1 scale for a Cell8 image
	var scale = 10.0
	var width = 80
	var height = 100 
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
	draw_colored_polygon(bgCoords, styles["0"].drawOps[0].color) 
	
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
				#this is just a circle for single points, size is style defined.
				draw_circle(polyCoords[0], s.sizePx * scale, s.color)
			elif (entry.gt == 2):
				#This is significantly faster than calling draw_line for each of these.
				draw_polyline(polyCoords, s.color, s.sizePx * scale)
			elif entry.gt == 3:
				#A single color, which is what I generally use. TODO: decide how the texture2d part should work.
				draw_colored_polygon(polyCoords, s.color) 
	print("Drawing done")
