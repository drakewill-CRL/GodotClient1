extends Node2D
class_name MineNode

@export var xPos = 0
@export var yPos = 0
@export var isMine = false
@export var neighbors = 0
@onready var panel =  $Panel
@onready var label = $Label

signal was_opened(this: MineNode)

#TODO: figure out how to flag spots in Godot. Long-press? check pressed and released?

func on_open():
	if panel.visible == false:
		return

	panel.visible = false
	label.visible = true
	
	#TODO: count neighbors here and set label text? This has no connections to the parent scene!
	was_opened.emit(self)
	
	#return !isMine
	
func set_text(val):
	label.text = val

func set_text_color(color):
	#TODO: let games set the text color after tapping a node. Ideally for reverse/pvp minesweeper.
	pass
