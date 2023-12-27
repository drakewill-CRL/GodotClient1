extends Node2D

var mineNodes = []

var mine_count = 10
var grid_size = 10
var padding_px = 2
var node_size_px = 40
var margin_x = 10
var margin_y = 10

func node_opened(minenode: MineNode):
	#This handles logic on which sub-tile was tapped.
	print("Tapped mine " + str(minenode.xPos) + "," + str(minenode.yPos))
	
	if (minenode.isMine == true):
		minenode.set_text("X")
		#lose.
	else:
		#count neighbors and update label
		var neighborCount = 0
		for x in range(minenode.xPos - 1, minenode.xPos + 2): #exclusive 2nd number
			for y in range(minenode.yPos - 1, minenode.yPos + 2):
				print(str(x) + "|" + str(y))
				if x > 0 and x < grid_size and y > 0 and y < grid_size:
					if mineNodes[x][y].isMine == true:
						neighborCount += 1
		minenode.set_text(str(neighborCount))
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	#create a 10x10 array of MineNodes
	var mine_node = preload("res://Minigames/Minesweeper/MineNode.tscn")
	
	for x in 10:
		mineNodes.append([])
		for y in 10:
			var thisNode = mine_node.instantiate()
			thisNode.name = "mineNode_" + str(x) + "_" + str(y)
			thisNode.xPos = x
			thisNode.yPos = y
			thisNode.was_opened.connect(node_opened)
			mineNodes[x].append(thisNode)
			add_child(thisNode)
			thisNode.position.x = margin_x + (x * 40) + (2 * x) #TODO: size and padding maybe should be vars.
			thisNode.position.y = margin_y + (y * 40) + (2 * y)
	
	#now pick mine positions
	var locations = []
	while (locations.size() < mine_count):
		var mine_x = randi() % grid_size
		var mine_y = randi() % grid_size
		
		var will_add = true
		for l in locations:
			if l.x == mine_x and l.y == mine_y:
				will_add = false
				break
		
		if will_add == true:
			locations.append({x = mine_x, y = mine_y})
	
	for l in locations:
		mineNodes[l.x][l.y].isMine = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
