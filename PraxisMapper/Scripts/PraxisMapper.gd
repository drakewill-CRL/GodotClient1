extends Node
class_name PraxisMapper

# Values used for login and auth
static var username
static var password
static var loginToken

#config values referenced by components
static var mapTileWidth = 320
static var mapTileHeight = 400
#static var debugStartingPlusCode = "85633QG4VV" #Elysian Park, Los Angeles, CA
static var debugStartingPlusCode = "86FRXXXPM8" #Ohio State University, Columbus, OH

#storage values for global access at any time.
static var currentPlusCode = '' #The Cell10 we are currently in.
static var lastPlusCode = '' #the previous Cell10 we visited.

signal plusCode_changed(current, previous)

#TODO: set this in auto-load to always run.
static var gps_provider

#TODO: use signals here so other scenes can hook into this.
func on_monitoring_location_result(location: Dictionary) -> void:
	var plusCode = PlusCodes.EncodeLatLon(location["latitude"], location["longitude"])
	if (plusCode != currentPlusCode):
		lastPlusCode = currentPlusCode
		currentPlusCode = plusCode
		plusCode_changed.emit(currentPlusCode, lastPlusCode)

func _ready():
	DirAccess.make_dir_absolute("user://MapTiles")
	gps_provider = Engine.get_singleton("GodotAndroidGpsProvider")
	if gps_provider != null:
		gps_provider.on_monitoring_location_result.connect(on_monitoring_location_result)
	else:
		print("GPS Provider not loaded (probably debugging on PC)")
		currentPlusCode = debugStartingPlusCode
		#lastPlusCode = debugStartingPlusCode
		#TODO: add the DebugMovement node to the scene tree.
	
