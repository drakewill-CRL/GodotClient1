extends Node
class_name PraxisMapper

# Values used for login/auth and server comms
static var username = ''
static var password = ''
static var authKey = '' #for normal security with a login
static var headerKey = '' #for header-only security
static var serverURL = '' #dedicated games want this to be a fixed value and not entered on the login screen.
#NOTE: serverURL should NOT end with a /. Changed from Solar2D's pattern.

#config values referenced by components
static var mapTileWidth = 320
static var mapTileHeight = 400
#static var debugStartingPlusCode = "85633QG4VV" #Elysian Park, Los Angeles, CA
static var debugStartingPlusCode = "86FRXXXPM8" #Ohio State University, Columbus, OH

#storage values for global access at any time.
static var currentPlusCode = '' #The Cell10 we are currently in.
static var lastPlusCode = '' #the previous Cell10 we visited.

signal plusCode_changed(current, previous)

#support components
static var gps_provider
static var reauthCode = 419 #AuthTimeout HTTP response
static var isReauthing = false #most calls should abort or wait if we're reauthing.

func forceChange(newCode):
	lastPlusCode = currentPlusCode
	currentPlusCode = newCode
	plusCode_changed.emit(currentPlusCode, lastPlusCode)

static func reauthListener(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var data = json.get_data()
		PraxisMapper.authKey = data.authToken
		isReauthing = false
	else:
		OS.delay_msec(1000)
		PraxisMapper.reauth()

static func reauth():
	if (isReauthing == true):
		return #TODO better handling/retry logic.
		
	isReauthing = true
	var request = HTTPRequest.new()
	var call = request.request(PraxisMapper.serverURL + "/Server/Login/" + PraxisMapper.username + "/" + PraxisMapper.password)

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
		var debugControlScene = preload("res://PraxisMapper/Controls/DebugMovement.tscn")
		var debugControls = debugControlScene.instantiate()
		add_child(debugControls)
		debugControls.position.x = 0
		debugControls.position.y = 0
		debugControls.z_index = 200

