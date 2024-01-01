extends Node
class_name EntitySkill

@onready var status : EntityStatus = $"../EntityStatus"

var entityData : Entity
var skillQueue : Dictionary #Turn : Array[ActiveSkill]

const ski : ActiveSkill = preload("res://resources/ShootArrow.tres")
var skill = ski

func _ready():
	entityData = get_parent().entityData
	initSkillQueue()

func attackTarget(target : Card):
	for eft in skill.skillEftArr:
		if eft.statusEffect.buff:
			target.getStatus().addBuff(eft.statusEffect,eft.tier,eft.turns)
		else:
			target.getStatus().addDebuff(eft.statusEffect,eft.tier,eft.turns)

func initSkillQueue():
	if entityData.skillDict.is_empty(): return
	for s in entityData.skillDict.values():
		if skillQueue.has(s.coolDown):
			skillQueue[s.coolDown].append(s)
		else:
			skillQueue[s.coolDown] = [s]

func _on_card_turn():
	var newQueue : Dictionary = {}
	for s in skillQueue.keys():
		if s == 0:
			newQueue[0] = skillQueue[0]
			continue
		for a in skillQueue[s]:
			if !newQueue.has(s-1):
				newQueue[s-1] = []
			newQueue[s-1].append(a)
	skillQueue.clear()
	skillQueue = newQueue
	newQueue.clear()

func getNextSkill() -> ActiveSkill:
	if skillQueue[0].is_empty(): return null
	return skillQueue[0].pick_random()

func resetSkill(s : ActiveSkill):
	for i in skillQueue[0]:
		if i == s:
			skillQueue[0].erase(s)
			var turn = s.coolDown
			if skillQueue.has(turn):
				skillQueue[turn].append(s)
			else:
				skillQueue[turn] = [s] 

func vampireEffect():
	if status.statusDict[Stat.T.vampire] > 0:
		pass

func revivalEffect():
	if status.statusDict[Stat.T.revival] > 0:
		pass

func threatEffect():
	if status.statusDict[Stat.T.threat] > 0:
		pass



