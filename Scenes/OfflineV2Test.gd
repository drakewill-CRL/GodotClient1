extends Node2D

@onready var request: PraxisEndpoints = $PraxisEndpoints

# Called when the node enters the scene tree for the first time.
func _ready():
	
	await PraxisCore.MakeMinOfflineTiles("86HWGG")


