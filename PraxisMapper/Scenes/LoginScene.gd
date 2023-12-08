extends Node2D

@onready var txtUsername: LineEdit = $txtUsername
@onready var txtPassword: LineEdit = $txtPassword
@onready var txtServer: LineEdit = $txtServer
@onready var request: HTTPRequest = $HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready():
	#TODO: check for saved credentials, set into textboxes if found.
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func login_completed(result, response_code, headers, body):
	request.request_completed.disconnect(login_completed)
	print("login complete")
	print(response_code)
	print(body)
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var data = json.get_data()
	print(data)
	#if successful, save name/pwd/server to file to load as auto-login next time.
	PraxisMapper.username = txtUsername.text
	PraxisMapper.password = txtPassword.text
	PraxisMapper.loginToken = data.authToken
	#Now, change to the post-login scene here.
	#get_tree().change_scene_to_file("res://Scenes/GpsTest.tscn")
	get_tree().change_scene_to_file("res://Scenes/test1.tscn")
	#get_tree().change_scene_to_file("res://Scenes/OverheadView.tscn")

func _on_btn_login_pressed():
	#here is where login logic goes.
	print("login pressed")
	request.request_completed.connect(login_completed)
	
	var call = request.request(txtServer.text + "/Server/Login/" + txtUsername.text + "/" + txtPassword.text)
	if (call != OK):
		pass #Todo see if this is necessary or can be handled in the complete call.


func _on_btn_create_acct_pressed():
	print("create pressed")
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
		
	#TODO: get stuff from data.
	#if successful, save name/pwd/server to file to load as auto-login next time.
