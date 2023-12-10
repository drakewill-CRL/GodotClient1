extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _gui_input(event):
	#this is what this is listening for to block touches cascading down farther.
	#TODO: test and confirm
	accept_event()
