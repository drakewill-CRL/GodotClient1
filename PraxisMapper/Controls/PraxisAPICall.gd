extends Node

# Based on the HTTPClient demo in the official docs. Used to make getting data a single function call.
# This simple class can do HTTP requests; it will not block, but it needs to be polled.

#For a game with a custom plugin, it'll basically want a node that creates an instance of this node,
#and hits call_url() with the correct parameters, then process the result accordingly and return that.
var http

func _init():
	var err = 0
	http = HTTPClient.new() # Create the Client.

	if (PraxisMapper.serverURL.contains(":")):
		var split = PraxisMapper.serverURL.split(":")
		err =  http.connect_to_host(split[0], int(split[1])) # Connect to host/port.
	else:
		err = http.connect_to_host(PraxisMapper.serverURL) # Connect to host/port.

	err =  http.connect_to_host("http://192.168.50.74", 5000) # Connect to host/port.
	assert(err == OK) # Make sure connection is OK.
	
	# Wait until resolved and connected.
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		if not OS.has_feature("web"):
			OS.delay_msec(25)
		else:
			await get_tree().process_frame

	print(http.get_status())
	assert(http.get_status() == HTTPClient.STATUS_CONNECTED) # Check if the connection was made successfully.

func call_url(endpoint, method = HTTPClient.METHOD_GET, body = ''):
	# Some headers
	var headers = [
		"AuthKey: " + PraxisMapper.authKey,
		"PraxisAuthKey: " + PraxisMapper.headerKey,
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]
	
	if !endpoint.begins_with("/"):
		endpoint = "/" + endpoint

	var err = http.request(method, endpoint, headers, body) # Request a page from the site (this one was chunked..)
	assert(err == OK) # Make sure all is OK.

	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		# Keep polling for as long as the request is being processed.
		http.poll()
		print("Requesting...")
		if OS.has_feature("web"):
			# Synchronous HTTP requests are not supported on the web,
			# so wait for the next main loop iteration.
			await get_tree().process_frame
		else:
			OS.delay_msec(25)

	assert(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED) # Make sure request finished well.

	print("response? ", http.has_response()) # Site might not have a response.

	if http.has_response():
		# If there is a response...

		headers = http.get_response_headers_as_dictionary() # Get response headers.
		print("code: ", http.get_response_code()) # Show response code.
		print("**headers:\\n", headers) # Show headers.

		# Getting the HTTP Body

		if http.is_response_chunked():
			# Does it use chunks?
			print("Response is Chunked!")
		else:
			# Or just plain Content-Length
			var bl = http.get_response_body_length()
			print("Response Length: ", bl)

		# This method works for both anyway
		var rb = PackedByteArray() # Array that will hold the data.

		while http.get_status() == HTTPClient.STATUS_BODY:
			# While there is body left to be read
			http.poll()
			# Get a chunk.
			var chunk = http.read_response_body_chunk()
			if chunk.size() == 0:
				if not OS.has_feature("web"):
					# Got nothing, wait for buffers to fill a bit.
					OS.delay_usec(10)
				else:
					await get_tree().process_frame
			else:
				rb = rb + chunk # Append to read buffer.
		# Done!

		print("bytes got: ", rb.size())
		var text = rb.get_string_from_utf8()
		print("Text: ", text)
		return rb #Let the caller decode this data the way they expect to have it.
