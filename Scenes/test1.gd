extends Node2D

@onready var mapTile = $MapTile

# Called when the node enters the scene tree for the first time.
func _ready():
	print("getting new tile")
	mapTile.GetTile("86HWGGGP")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
