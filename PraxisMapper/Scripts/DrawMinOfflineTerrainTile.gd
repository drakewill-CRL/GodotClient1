extends Node2D

#This is for drawing map tiles directly in the client from Offline/V2 data
#This file handles terrain IDs, so that terrain types and unnamed places can be identified by the game.

var theseentries = null
var thisscale = 1

#NOTE: drawOps are drawn in order, so the earlier one has the higher LayerId in PraxisMapper style language.
#the value/id/order is the MatchOrder for the style in PraxisMapper server


#This is set from outside.
var style


func DrawOfflineTerrainTile(entries, scale):
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
		
		var r = (int(entry.tid) % 256) / 256.0
		var g = (int(entry.tid / 256) % 256) / 256.0
		var b = (int(entry.tid / 65536) % 256) / 256.0
		var terrainColor = Color(r, g, b)
		var lineSize = 1.0 * scale
		var thisStyle = style[str(entry.tid)]
		
		var point = entry.c.split(",")
		var center = Vector2(int(point[0]) * scale, int(point[1]) * scale)
		draw_circle(center, entry.r, terrainColor)
	print("Drawing done")
