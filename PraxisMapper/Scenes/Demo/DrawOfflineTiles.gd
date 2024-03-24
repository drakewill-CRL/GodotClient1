extends Node2D

var plusCode = "86HWGG"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	DebugMenu.style = DebugMenu.Style.VISIBLE_DETAILED
	
	await get_tree().create_timer(0.1).timeout
	await $DrawOffline.GetAndProcessData(plusCode)
	print("main draw offline tiles scene done.")
	FillScrollView() #Move back to end after testing


func FillScrollView():
	var yCount = 0
	var xCount = 0
	for letterY in PlusCodes.CODE_ALPHABET_.reverse():
		var hbox = HBoxContainer.new()
		hbox.position.y = yCount * 500
		for letterX in PlusCodes.CODE_ALPHABET_:
			#We are going to make an HBoxContainer with all of the images in order.
			var nextSprite = TextureRect.new()
			#nextSprite.position.x = xCount * 100
			#nextSprite.position.y = yCount * 100
			var img = Image.load_from_file("user://MapTiles/" + plusCode + letterY + letterX + "-1.png")
			var tex = ImageTexture.create_from_image(img)
			nextSprite.texture = tex
			#$sc/vbox.add_child(nextSprite)
			hbox.add_child(nextSprite)
		$sc/vbox.add_child(hbox)

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://PraxisMapper/Scenes/DemoSelect.tscn")
