extends Node2D

@onready var statDisplay : TextEdit = $Camera2D/Control/Panel/TextEdit

func _ready():
	Signals.connect("displayStat", displayStats)

func displayStats(card : Card):
	statDisplay.text = card.name

