extends Node2D

@onready var request: PraxisEndpoints = $PraxisEndpoints

# Called when the node enters the scene tree for the first time.
func _ready():
	PraxisCore.MakeOfflineTiles("86HWGG", 4)
	#$OfflineData.GetAndProcessData("86HWGG", 4, "mapTiles")
	#return
			
	#Bonus fun attempt, and it works if the scale value is small enough:
	#viewport.size = Vector2i(80 * 20 * scale, 100 * 20 * scale) #This subviewport draws the Cell8 image.
	#camera.position.x = 0
	#camera.position.y = 100 * 20 * scale * -1
	#await RenderingServer.frame_post_draw
	#var texMax = viewport.get_texture() 
	#await get_tree().create_timer(2).timeout
	#var imgMax = texMax.get_image() # Get rendered image
	#await get_tree().create_timer(2).timeout
	#imgMax.save_png("user://" + plusCode + ".png") # Save to disk
	#print("saved image " + plusCode)
	
