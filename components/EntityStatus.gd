extends Node
class_name EntityStatus

@onready var healthBar : ProgressBar = $"../Healthbar"
@onready var stat : EntityStat = $"../EntityStat"

var statusDict : Dictionary = {} #Stat.T : Stat

var buff : Dictionary = {} #id : Effect
var debuff : Dictionary = {} #id : Effect

func _ready():
	initStatus()
	healthBar.max_value = statusDict[Stat.T.hp].getValue()
	healthBar.value = statusDict[Stat.T.hp].currentValue

func initStatus():
	for t in stat.statDict.keys():
		statusDict[t] = Stat.new(stat.getStatValue(t))

func updateHealth(value : int):
	if value == 0: return
	var calValue = value
	if value < 0:
		calValue = calculateDamage(abs(value)) * -1
	if(statusDict[Stat.T.hp].currentValue + calValue > statusDict[Stat.T.hp].getValue()):
		statusDict[Stat.T.hp].currentValue = statusDict[Stat.T.hp].getValue()
	elif (statusDict[Stat.T.hp].currentValue + calValue <= 0):
		statusDict[Stat.T.hp].currentValue = 0
		get_parent().destorySelf()
	else:
		statusDict[Stat.T.hp].currentValue += calValue
	healthBar.max_value = statusDict[Stat.T.hp].getValue()
	healthBar.value = statusDict[Stat.T.hp].currentValue

func _on_card_turn():
	for b in buff.keys():
		buff[b].turns -= 1
		if buff[b].turns <= 0:
			buff.erase(b)
	for d in debuff.keys():
		debuff[d].turns -= 1
		if debuff[d].turns <= 0:
			debuff.erase(d)

func addBuff(e : StatusEffect, tier : int, turns : int):
	statusDict[e.type].addModifier(e.id,e.statModArr[tier])
	buff[e.id] = Effect.new(e,tier,turns)

func addDebuff(e : StatusEffect, tier : int, turns : int):
	statusDict[e.type].addModifier(e.id,e.statModArr[tier])
	debuff[e.id] = Effect.new(e,tier,turns)

func removeRanDebuff(num : int):
	for n in range(num):
		var i = debuff.keys().pick_random()
		statusDict[debuff[i].statusEft.type].removeModifier(i)
		debuff.erase(i)

func removeRanBuff(num : int):
	for n in range(num):
		var i = buff.keys().pick_random()
		statusDict[buff[i].statusEft.type].removeModifier(i)
		buff.erase(i)

func removeAllDebuff():
	debuff.clear()

func removeAllBuff():
	buff.clear()

func calculateDamage(damage : int) -> int:
	var d = damage - statusDict[Stat.T.def].getValue()
	if d < 0:
		return 0
	return d

func getCurrentValue(type : Stat.T) -> int:
	return statusDict[type].currentValue

class Effect:
	var statusEft : StatusEffect
	var tier : int
	var turns : int
	func _init(e : StatusEffect,t : int, turn : int):
		statusEft = e
		tier = t
		turns = turn
