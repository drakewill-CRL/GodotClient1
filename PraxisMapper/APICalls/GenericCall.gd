extends Node2D

@onready var request: HTTPRequest = $HTTPRequest
#this version is going to use signals insted of waiting for a response in a single call.

signal response_data(body)

func response_received(result, responseCode, headers, body):
	#TODO: automatic reauth if possible.
	print('response received')
	request.request_completed.disconnect(response_received)
	if result != 0 and result < 299:
		response_data.emit(body)

func callEndpoint(url):
	request.request_completed.connect(response_received)
	var ok = request.request(PraxisMapper.serverURL + url)
	print('request called')
	
	#this probably doesn't work.
	#var results = await response_received
	#print('results awaited successfully')
	#return results
