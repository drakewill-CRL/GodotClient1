extends Node2D

@onready var request: HTTPRequest = $HTTPRequest

func response_received():
	

func callEndpoint(url):
	request.request_completed.connect(response_received)	
	var ok = request.request(PraxisMapper.serverURL + url)
	



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
