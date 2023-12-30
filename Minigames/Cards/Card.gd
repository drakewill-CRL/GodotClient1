extends Node
class_name Card

#a class/script for handling individual cards in a Deck.

static var base_deck: Array

static func new_deck():
	var deck = base_deck.duplicate()
	deck.shuffle()
	return deck


enum CardSuit {
	CLUBS,
	DIAMONDS,
	HEARTS,
	SPADES
}

static var suitText = ["C", "D", "H", "S"]

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
static var valueText = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

@export var cardSuit: int
@export var cardValue: int
@export var faceUp: bool

static func _static_init():
	var deck = []
	for suit in CardSuit:
		for value in CardValue:
			deck.append({suit: suit, value: value})
	base_deck = deck

func init(card_suit: int, card_value: int, face_up:bool = true):
	cardSuit = card_suit
	cardValue = card_value
	faceUp = face_up	

func _ready():
	#TODO: 
	pass
	
func flip():
	faceUp = !faceUp
	
func update_appearance():
	$Suit.text = suitText[cardSuit]
	$Value.text = valueText[cardValue]
	$cardback.visible = !faceUp
	
