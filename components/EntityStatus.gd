extends Node
class_name EntityStatus

@onready var healthBar : ProgressBar = $"../Healthbar"
@onready var stat : EntityStat = $"../EntityStat"

var statusDict : Dictionary = {} #Stat.T : MaxStat

var buff : Dictionary = {}
var debuff : Dictionary = {}

func _ready():
	initStatus()
	healthBar.max_value = statusDict[Stat.T.hp].max
	healthBar.value = statusDict[Stat.T.hp].cur

func initStatus():
	for t in Stat.T:
		statusDict[t] = MaxStat.new(stat.getStatValue(Stat.T[t]))

func updateHealth(value):
	if(statusDict[Stat.T.hp].cur + value > statusDict[Stat.T.hp].max):
		statusDict[Stat.T.hp].cur = statusDict[Stat.T.hp].max
	elif (statusDict[Stat.T.hp].cur + value <= 0):
		statusDict[Stat.T.hp].cur = 0
		get_parent().destorySelf()
	else:
		statusDict[Stat.T.hp].cur += value
	healthBar.max_value = statusDict[Stat.T.hp].max
	healthBar.value = statusDict[Stat.T.hp].curhp

func _on_card_turn():
	for b in buff.keys():
		buff[b].turns -= 1
		if buff[b].turns <= 0:
			buff.erase(b)
	for d in debuff.keys():
		debuff[d].turns -= 1
		if debuff[d].turns <= 0:
			debuff.erase(d)

func addBuff(e : StatusEffect, turns : int):
	buff[e.id] = StatusEffectTurn.new(e,turns)

func addDebuff(e : StatusEffect, turns : int):
	debuff[e.id] = StatusEffectTurn.new(e,turns)

func removeRanDebuff(num : int):
	for n in range(num):
		var i = debuff.keys().pick_random()
		debuff.erase(i)

func removeRanBuff(num : int):
	for n in range(num):
		var i = buff.keys().pick_random()
		buff.erase(i)

func removeAllDebuff():
	debuff.clear()

func removeAllBuff():
	buff.clear()

func getCurrentValue(type : Stat.T) -> int:
	return statusDict[type].cur

class StatusEffectTurn:
	var statusEft : StatusEffect
	var turns : int
	func _init(e : StatusEffect, turn : int):
		statusEft = e
		turns = turn

class MaxStat:
	var max : int
	var cur : int
	func _init(m : int):
		max = m
		cur = m
