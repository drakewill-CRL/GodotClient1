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
		$drawer.mapTiles = info	

	request.response_data.connect(call_done)
	request.OfflineV2("86FQQP8H")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	$drawer.mapTiles = info	 #drawer as a verb, not a noun.

func call_done(data):
	print("Data complete!")
	var json = JSON.new()
	json.parse(data.get_string_from_utf8())
	var info = json.get_data()
	print(info)
	
	$drawer.DrawOfflineTile(info.entries)
