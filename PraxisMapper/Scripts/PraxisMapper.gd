extends Node
class_name PraxisMapper

#NOTE: PraxisMapper is the class name for static values.
#For the singleton instance in autoload, use PraxisCore

#Current limitation: this app asks for permissions on first launch. If granted, it needs restarted
#before GPS will work correctly.

# Values used for login/auth and server comms
static var username = ''
static var password = ''
static var authKey = '' #for normal security with a login
static var headerKey = '' #for header-only security
static var serverURL = '' #dedicated games want this to be a fixed value and not entered on the login screen.
#NOTE: serverURL should NOT end with a /. Changed from Solar2D's pattern.

#config values referenced by components
static var mapTileWidth = 320 #TODO: load these from the server eventually
static var mapTileHeight = 400
#This variable should exist for debugging purposes, but I've provided a few choices for convenience.
#static var debugStartingPlusCode = "85633QG4VV" #Elysian Park, Los Angeles, CA, USA
#static var debugStartingPlusCode = "87G8Q2JMGF" #Central Park, New York City, NY, USA
#static var debugStartingPlusCode = "8FW4V75W25" #Eiffel Tower Garden, France
#static var debugStartingPlusCode = "9C3XGV349C" #The Green Park, London, UK
#static var debugStartingPlusCode = "8Q7XMQJ595" #Kokyo Kien National Garden, Tokyo, Japan
#static var debugStartingPlusCode = "8Q336FJCRV" #Peoples Park, Shanghai, China
#static var debugStartingPlusCode = "7JWVP5923M" #Shalimar Bagh, Delhi, India
static var debugStartingPlusCode = "86FRXXXPM8" #Ohio State University, Columbus, OH, USA

#System global values
#Resolution of PlusCode cells in degrees
const resolutionCell12Lat = .000025 / 5
const resolutionCell12Lon = .00003125 / 4; 
const resolutionCell11Lat = .000025;
const resolutionCell11Lon = .00003125; 
const resolutionCell10 = .000125; 
const resolutionCell8 = .0025; 
const resolutionCell6 = .05; 
const resolutionCell4 = 1; 
const resolutionCell2 = 20;

#storage values for global access at any time.
static var currentPlusCode = '' #The Cell10 we are currently in.
static var lastPlusCode = '' #the previous Cell10 we visited.

#signals for components that need to respond to it.
signal plusCode_changed(current, previous)
signal location_changed(dictionary)

#support components
static var gps_provider
static var reauthCode = 419 #AuthTimeout HTTP response
static var isReauthing = false #most calls should abort or wait if we're reauthing.

static func forceChange(newCode):
	lastPlusCode = currentPlusCode
	currentPlusCode = newCode
	PraxisCore.plusCode_changed.emit(currentPlusCode, lastPlusCode)

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

func on_monitoring_location_result(location: Dictionary) -> void:
	location_changed.emit(location)
	print("location changed" + str(location))
	var plusCode = PlusCodes.EncodeLatLon(location["latitude"], location["longitude"])
	if (plusCode != currentPlusCode):
		lastPlusCode = currentPlusCode
		currentPlusCode = plusCode
		plusCode_changed.emit(currentPlusCode, lastPlusCode)
		print("new plusCode: " + plusCode)
		
func perm_check(granted):
	print("permissions: " + granted)
	gps_provider.on_monitoring_location_result.connect(on_monitoring_location_result)
	gps_provider.start_monitoring(gps_provider.get_accuracy_high(), 500, 0.5, true)

func _ready():
	DirAccess.make_dir_absolute("user://MapTiles")
	DirAccess.make_dir_absolute("user://NameTiles")
	DirAccess.make_dir_absolute("user://Styles")
	DirAccess.make_dir_absolute("user://Offline")
	gps_provider = Engine.get_singleton("GodotAndroidGpsProvider")
	if gps_provider != null:
		#TODO: GPS location currently works. GPS Permisisons currently do NOT. Needs manually enabled.
		#gps_provider.on_request_precise_gps_result.connect(perm_check)
		#gps_provider.request_precise_gps_permission()
		var allowed = OS.request_permissions()
		if (allowed == true): #permissions were granted on a previous run.
			print("allowed")
			gps_provider.on_monitoring_location_result.connect(on_monitoring_location_result)
			gps_provider.start_monitoring(gps_provider.get_accuracy_high(), 500, 0.5, true)
			#print('requesting permissions')
		else: #we had to ask for permissions, logic kept running.
			print("no permissions yet.")
			#TODO: loop/check until we do have permissions? Or inform user they need to grant?
			
		#print('perm request sent')
	else:
		print("GPS Provider not loaded (probably debugging on PC)")
		currentPlusCode = debugStartingPlusCode
		var debugControlScene = preload("res://PraxisMapper/Controls/DebugMovement.tscn")
		var debugControls = debugControlScene.instantiate()
		add_child(debugControls)
		debugControls.position.x = 0
		debugControls.position.y = 0
		debugControls.z_index = 200
		
func MakeOfflineTiles(plusCode, scale):
	var offlineNode = preload("res://PraxisMapper/Controls/OfflineData.tscn")
	var offlineInst = offlineNode.instantiate()
	add_child(offlineInst)
	await offlineInst.GetAndProcessData(plusCode, scale, "mapTiles")
	await offlineInst.tiles_saved
	remove_child(offlineInst)

static func GetNameFromNameTile(plusCode8Tile, pixelX, pixelY):
	var locationData = FileAccess.open("user://Offline/" + plusCode8Tile.substr(0,6) + ".json", FileAccess.READ)
	var json = JSON.new()
	var textData = locationData.get_as_text()
	json.parse(textData)
	var mapData = json.data
		
	var nameTile = Image.load_from_file("user://NameTiles/" + plusCode8Tile + "-4.png")
	var pixel = nameTile.get_pixel(pixelX, pixelY)
	if (pixel == Color.BLACK):
		return ""
	
	var nameTableId = pixel.r8 + pixel.g8 * 255 + pixel.b8 * 65535
	if (nameTableId == 0):
		return ""

	var name = mapData.nameTable[str(nameTableId)]
	return name
