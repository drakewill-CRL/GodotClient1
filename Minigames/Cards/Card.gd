extends Node
class_name Card

#a class/script for handling individual cards in a Deck.

static var base_deck: Array

enum CardSuit {
	CLUBS,
	DIAMONDS,
	HEARTS,
	SPADES
}

enum CardValue {
	ACE = 1,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	NINE,
	TEN,
	JACK,
	QUEEN,
	KING
}

@export var cardSuit: int
@export var cardValue: int
@export var faceUp: bool

static func _static_init():
	var deck = []
	for suit in CardSuit:
		for value in CardValue:
			deck.append({suit: suit, value: value})
	base_deck = deck

func init(card_suit: int, card_value: int):
	cardSuit = card_suit
	cardValue = card_value
	
func flip():
	faceUp = !faceUp
	
static func new_deck():
	var deck = base_deck.duplicate()
	deck.shuffle()
	return deck
