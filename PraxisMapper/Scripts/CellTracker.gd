extends RefCounted
class_name CellTracker

static var visited = {}

static func Add(plusCode10):
	visited[plusCode10] = true
	
static func Remove(plusCode10):
	visited.erase(plusCode10)
	
#TODO: function to quickly draw this data to a texture.
