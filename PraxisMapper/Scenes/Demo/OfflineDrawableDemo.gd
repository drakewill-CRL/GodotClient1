extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	#We're going to do some of the basic functions manually here for demo purposes
	#NOTE: this selected area is A LOT for mobile to handle. Loading, creating, and scrolling this 
	#is very, very slow. This won't fly for live stuff, but it should be ok if it's done once 
	#while drawing images.
	
	await get_tree().create_timer(0.1).timeout #let the scene load before we draw stuff.
	
	$OfflineData.plusCode = "849VQH"
	$OfflineData.GetStyle()
	var mapfile = FileAccess.open("res://PraxisMapper/Scenes/Demo/849VQH.json", FileAccess.READ)
	var json = JSON.new()
	json.parse(mapfile.get_as_text())
	#$OfflineData.mapData = json.data
	#$OfflineData.CreateAllTiles()
	
	var stylefile = FileAccess.open("res://PraxisMapper/Styles/mapTiles.json", FileAccess.READ)
	var stylejson = JSON.new()
	stylejson.parse(stylefile.get_as_text())
	
	
	$sc/cc/MapDraw.style = stylejson.data
	$sc/cc/MapDraw.DrawOfflineTile(json.data.entries["mapTiles"], 1)




