extends Node2D

@onready var statDisplay : TextEdit = $Camera2D/Control/Panel/TextEdit
var cards : Array[Card] = []

func _ready():
	Signals.connect("displayStat", displayStats)

func displayStats(card : Card):
	cards.clear()
	cards.append(card)
	statDisplay.text = card.name

