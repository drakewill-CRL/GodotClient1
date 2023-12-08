extends RefCounted
class_name PlusCodes

var SEPARATOR_ = '+'
static var CODE_ALPHABET_ = '23456789CFGHJMPQRVWX'

#var GRID_COLUMNS_ = 4
#var GRID_ROWS_ = 5
#note: a reasonable alternative would be a 3x3 grid in a 9-char code set. 
#would be longer codes but could be number-only, and then indexable similar to S2 codes but 
#in regular rectangles instead.

#for decoding the 11th digit?
#var GRID_ROW_MULTIPLIER = 3125
#var GRID_COL_MULTIPLIER = 1024


static func EncodeLatLon(lat, lon):
	return EncodeLatLonSize(lat, lon, 10)
	
static func EncodeLatLonSize(lat, lon, size):
	var code = ''
	var currentLat = int(floor((lat + 90) * 8000))
	var currentLon = int(floor((lon + 180) * 8000))
	
	#if (size == 11):
		#currentLat *= 5
		#currentLon *= 4
		#more
	#else:
		#pass
		
	var nextLatChar = 0
	var nextLonChar = 0
	for i in 5:
		print(str(lat) + ", " + str(lon))
		nextLonChar = (currentLon % 20)
		nextLatChar = (currentLat % 20)
		
		code = CODE_ALPHABET_.substr(nextLatChar, 1) + CODE_ALPHABET_.substr(nextLonChar, 1) + code
		currentLat = floor(currentLat / 20)
		currentLon = floor(currentLon / 20)
		print(code)
		
	#if (size == 11):
		#something
	
	return code
	
static func RemovePlus(code):
	return code.replace("+", "")
	
static func ShiftCode(code, xChange, yChange):
	#change the given PlusCode to the one with the final X and Y characters moved
	# the given position count (EX: 842255PP, 2, -1 returns 842255MR
	pass
	
