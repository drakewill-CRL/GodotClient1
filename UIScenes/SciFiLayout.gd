extends Node2D

var bgColor = "#222034" #dark purple used in asepreite bg png
var shiftWaitSeconds = 5
var shiftDurationSeconds = 3

@onready var modulator: CanvasModulate = $UIFrame1/FrameRect/CanvasModulate


# Called when the node enters the scene tree for the first time.
func _ready():
	$UIFrame1/FrameRect/Timer.wait_time = shiftWaitSeconds
	$UIFrame1/FrameRect/Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func pick_and_shift():
	print("pick shift called")
	var tween = get_tree().create_tween() #don't reuse these
	tween.tween_property(modulator, "color", Color.from_hsv(randf(), 1.0, 1.0), shiftDurationSeconds).set_trans(Tween.TRANS_BOUNCE)
