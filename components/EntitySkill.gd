extends Node
class_name EntitySkill

@onready var status : EntityStatus = $"../EntityStatus"

var skillDict : Dictionary #ID : ActiveSkill
var skillQueue : Dictionary #Turn : Array[ActiveSkill]

func attackTarget(target : Card):
	var skill = getNextSkill()
	for i in range(skill.statEftArr.size()):
		if skill.statEftArr[i].buff:
			target.getStatus().addBuff(skill.statEftArr[i], skill.statEffectChance[i])

func initSkillQueue():
	if skillDict.is_empty(): return
	for s in skillDict.values():
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
	return skillQueue[0].pick_random()

func resetSkill(s : ActiveSkill):
	for i in skillQueue[0]:
		if i == s:
			skillQueue[0].erase(s)
			var turn = s.coolDown
			if skillQueue.has(s.coolDown):
				skillQueue[s.coolDown].append(s)
			else:
				skillQueue[s.coolDown] = [s] 

func addSkill(s : ActiveSkill):
	skillDict[s.id] = s

func removeSkill(s : ActiveSkill):
	skillDict[s.id] = s

func vampireEffect():
	if status.statusDict[Stat.T.vampire] > 0:
		pass

func revivalEffect():
	if status.statusDict[Stat.T.revival] > 0:
		pass

func threatEffect():
	if status.statusDict[Stat.T.threat] > 0:
		pass



