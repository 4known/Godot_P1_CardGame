extends Node
class_name EntityStatus

@onready var healthBar : ProgressBar = $"../Healthbar"
@onready var stat : EntityStat = $"../EntityStat"

var status : Dictionary = {} #Stat.T : MaxStat

var buff : Dictionary = {}
var debuff : Dictionary = {}

func _ready():
	initStatus()
	healthBar.max_value = status[Stat.T.hp].max
	healthBar.value = status[Stat.T.hp].cur

func initStatus():
	for t in Stat.T:
		status[t] = MaxStat.new(stat.getStatValue(t))

func updateHealth(value):
	if(status[Stat.T.hp].cur + value > status[Stat.T.hp].max):
		status[Stat.T.hp].cur = status[Stat.T.hp].max
	elif (status[Stat.T.hp].cur + value <= 0):
		status[Stat.T.hp].cur = 0
		get_parent().destorySelf()
	else:
		status[Stat.T.hp].cur += value
	healthBar.max_value = status[Stat.T.hp].max
	healthBar.value = status[Stat.T.hp].curhp

func _on_card_turn():
	for b in buff.keys():
		buff[b].turns -= 1
	for d in debuff.keys():
		debuff[d].turns -= 1

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

func getHp() -> int:
	return status[Stat.T.hp].cur

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
