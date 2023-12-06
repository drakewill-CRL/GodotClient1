extends Node2D


@onready var txtUsername: Label = $txtUsername
@onready var txtPassword: Label = $txtPassword
@onready var txtServer: Label = $txtServer

# Called when the node enters the scene tree for the first time.
func _ready():
	#TODO: check for saved credentials, set into textboxes if found.
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func login_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var data = json.get_data()
	#TODO: get stuff from data.
	#if successful, save name/pwd/server to file to load as auto-login next time.
	pass

func _on_btn_login_pressed():
	#here is where login logic goes.
	var request = HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(login_completed)
	
	var call = request.request(txtServer.text + "/Server/Login/" + txtUsername.text + "/" + txtPassword.text)
	if (call != OK):
		pass #Todo see if this is necessary or can be handled in the complete call.
