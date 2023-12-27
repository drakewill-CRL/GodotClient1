extends Node2D

var deck: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func new_deck():
	deck = Card.new_deck()
	

func count_deck():
	#blackjack doesnt care about suits, only count values.
	var count_dict = {}
	for card in deck:
		if (count_dict[card.value] == null):
			count_dict[card.value] = 1
		else:
			count_dict[card.value] += 1
	return count_dict
