extends Node2D

#This is for drawing item NAMES onto a maptile from OfflineV2 data
#Its nearly identical in logic, except this will use the name index and make up a color for it.

var theseentries = null
var thisscale = 1

#NOTE: drawOps are drawn in order, so the earlier one has the higher LayerId in PraxisMapper style language.
#the value/id/order is the MatchOrder for the style in PraxisMapper server


#This is set from outside.
var style


func DrawOfflineNameTile(entries, scale):
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
	var width = 80 * 20 * 16 #= 25600
	var height = 100  * 20 * 20 #= 40000
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
	draw_colored_polygon(bgCoords, Color.BLACK) 
	
	#entries has a big list of coord sets as strings
	for entry in theseentries:
		#TODO get style rule color and size for drawing here
		#TODO: loop here for each style draw rule entry.
		
		if (entry.has("nid")):
			var thisStyle = style[str(entry.tid)]
			#THESE are the integer values, but Godot only makes colors with 0-1 range when passing them in.
			var r = (int(entry.nid) % 256) / 256.0
			var g = (int(entry.nid / 256) % 256) / 256.0
			var b = (int(entry.nid / 65536) % 256) / 256.0
			var nameColor = Color(r, g, b)
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
					draw_circle(polyCoords[0], s.sizePx * 2.0 * scale * 5, nameColor)
				elif (entry.gt == 2):
					#This is significantly faster than calling draw_line for each of these.
					draw_polyline(polyCoords, nameColor, s.sizePx * scale * 5) #no antialiasing, colors matter.
				elif entry.gt == 3:
					#A single color, which is what I generally use. TODO: decide how the texture2d part should work.
					draw_colored_polygon(polyCoords, nameColor) 

