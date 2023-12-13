extends Node2D

@onready var txtUsername: LineEdit = $txtUsername
@onready var txtPassword: LineEdit = $txtPassword
@onready var txtServer: LineEdit = $txtServer
@onready var lblError: Label = $lblError
@onready var request: HTTPRequest = $HTTPRequest

#TODO: move passkey to a variable and change it.

# Called when the node enters the scene tree for the first time.
func _ready():
	#TODO: check for saved credentials, set into textboxes if found.
	var lastData = FileAccess.open_encrypted_with_pass("user://savedData.access", FileAccess.READ, "passkeyGoesHere")
	if (lastData != null):
		var data = lastData.get_as_text().split("|")
		if (data[2].ends_with('/')):
			data[2] = data[2].substr(0, data[2].length() - 2)
		lastData.close()
		txtUsername.text = data[0]
		txtPassword.text = data[1]
		txtServer.text = data[2]
		_on_btn_login_pressed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func login_completed(result, response_code, headers, body):
	request.request_completed.disconnect(login_completed)
	print("login complete")
	print(response_code)
	print(body)
	
	if (response_code == 0):
		lblError.text = "Login Failed: No response from server"
		return
	
	if (response_code > 299):
		lblError.text = "Login Failed: " +  str(response_code) + " " + body
		return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var data = json.get_data()
	print(data)
	#if successful, save name/pwd/server to file to load as auto-login next time.
	var authData = FileAccess.open_encrypted_with_pass("user://savedData.access", FileAccess.WRITE, "passkeyGoesHere")
	authData.store_string(txtUsername.text + "|" + txtPassword.text + "|" +txtServer.text)
	authData.close()
	
	PraxisMapper.username = txtUsername.text
	PraxisMapper.password = txtPassword.text
	PraxisMapper.serverURL = txtServer.text
	PraxisMapper.authKey = data.authToken
	#Now, change to the post-login scene here.
	#get_tree().change_scene_to_file("res://Scenes/GpsTest.tscn")
	#get_tree().change_scene_to_file("res://Scenes/test1.tscn")
	get_tree().change_scene_to_file("res://Scenes/OverheadView.tscn")

func _on_btn_login_pressed():
	#here is where login logic goes.
	print("login pressed")
	lblError.text = "Logging in...."
	request.request_completed.connect(login_completed)
	
	var call = request.request(txtServer.text + "/Server/Login/" + txtUsername.text + "/" + txtPassword.text)
	if (call != OK):
		pass #Todo see if this is necessary or can be handled in the complete call.


func _on_btn_create_acct_pressed():
	print("create pressed")
	lblError.text = "Creating account...."
	request.request_completed.connect(createCompleted)
	
	var call = request.request(txtServer.text + "/Server/CreateAccount/" + txtUsername.text + "/" + txtPassword.text, 
	[], HTTPClient.METHOD_PUT)
	if (call != OK):
		pass #Todo see if this is necessary or can be handled in the complete call.

func createCompleted(result, response_code, _headers, body):
	request.request_completed.disconnect(createCompleted)
	print("create complete")
	print(response_code)
	print(body)
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var data = json.get_data()
	if (data == true):
		_on_btn_login_pressed()
	else:
		print("Create failed")
