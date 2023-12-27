extends Node2D

@onready var modulator: CanvasModulate = $CanvasLayer/Panel/CanvasModulate
@onready var timer:Timer = $Timer
var shiftEverySeconds = 5
var shiftDurationSeconds = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = shiftEverySeconds
	timer.start()

func pick_and_shift():
	print("timer fired, shifting")
	var tween = get_tree().create_tween() #don't reuse these!
	var color = Color.from_hsv(randf(), 1.0, 1.0)
	tween.tween_property(modulator, "color", color, shiftDurationSeconds)
