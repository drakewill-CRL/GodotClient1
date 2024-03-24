extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func DrawImagesTest():
	get_tree().change_scene_to_file("res://PraxisMapper/Scenes/Demo/DrawOfflineTiles.tscn")

func GpsTest():
	get_tree().change_scene_to_file("res://Scenes/GpsTest.tscn")
	
func OfflineDrawTest():
	get_tree().change_scene_to_file("res://PraxisMapper/Scenes/Demo/OfflineDrawableDemo.tscn")

func EnableGps():
	var allowed = OS.request_permissions()
	if (allowed == true):
		$lblGranted.visible = true
		
