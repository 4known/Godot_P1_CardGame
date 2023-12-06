extends Node2D

@onready var statDisplay : TextEdit = $Camera2D/Control/Panel/TextEdit

func _ready():
	Signals.connect("displayStat", displayStats)

func displayStats(card : Card):
	var text = card.name + "\n"
	
	var buff = card.getStatus().buff
	for b in buff.keys():
		text += str(buff[b].name) + ", "
	text += "\n"
	var debuff = card.getStatus().debuff
	for d in debuff.keys():
		text += str(debuff[d].statusEft.id) + ", "
	text += "\n"
	
	var stats = card.getStat().statDict
	for s in stats.keys():
		text += str(Stat.T.keys()[s]) + ": " + str(card.getStatus().statusDict[s].cur) + "\n"
	statDisplay.text = text

