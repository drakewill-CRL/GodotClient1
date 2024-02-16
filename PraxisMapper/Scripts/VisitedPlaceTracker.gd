extends RefCounted
class_name VisitedPlaces

var allPlaces = {} #key is placename_plusCode6, value is dictionary (default: time = unix system time of visit.
var fileName = "user://Data/Visited.json"

#Places are stored by name and plusCode6
#EX: Main Park_223344

func Load():
	var recentFile = FileAccess.open(fileName, FileAccess.READ_WRITE)
	if (recentFile == null):
		pass
		#TODO: create file?
	else:
		var json = JSON.new()
		json.parse(recentFile.get_as_text())
		var info = json.get_data()
		recentFile.close()
	
func Save():
	var recentFile = FileAccess.open(fileName, FileAccess.WRITE)
	if (recentFile == null):
		print(FileAccess.get_open_error())
	
	var json = JSON.new()
	recentFile.store_string(json.stringify(allPlaces))
	recentFile.close()

func Add(place, plusCode6):
	allPlaces[place + "_" + plusCode6] = { timeFirstVisited = Time.get_unix_time_from_system()}

func isFirstVisit(place, plusCode6):
	if allPlaces.find_key(place + "_" + plusCode6):
		return false
	
	Add(place, plusCode6)
	return true;

func GetInfo(place, plusCode6):
	return allPlaces[place + "_" + plusCode6]

func SetInfo(place, plusCode6, data_dict):
	allPlaces[place + "_" + plusCode6] = data_dict
