extends Node2D
#This is for drawing map tiles directly in the client from Offline/V2 data

#TODO: Update this to use the minimum data format
#Cell10 resolution, all points with c and r values instead of p.
#And move this logic to other DrawMin scripts

var theseentries = null
var thisscale = 1

#NOTE: drawOps are drawn in order, so the earlier one has the higher LayerId in PraxisMapper style language.
#the value/id/order is the MatchOrder for the style in PraxisMapper server

#This is set from outside.
var style  #same logic as for NameTiles


func DrawOfflineTile(entries, scale):
	theseentries = entries
	thisscale = scale
	queue_redraw()

func _draw():
	if theseentries == null:
		return
	
	#TODO: determine background color for image and fill that first. Depends on style.
	#for dev testing, this is the default x1 scale for a Cell8 image
	var scale = thisscale
	var width = 80 * 20 #= 1600
	var height = 80  * 20 #= 1600
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
	draw_colored_polygon(bgCoords, "#f2eef9") 
	
	#entries has a dictionary, each entry is a big list of coord sets as strings
	for entry in theseentries:
		print(entry)
		var thisStyle = style[str(entry.tid)]		
		var point = entry.c.split(",")
		var center = Vector2(int(point[0]) * scale, int(point[1]) * scale)
		
		for s in thisStyle.drawOps:
			#TODO: draw multiples? Probably not for this. Ensure this style is 1-op per item.
			draw_circle(center, entry.r, "#" + s.color)
	print("Drawing done")
