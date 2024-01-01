extends Resource
class_name Entity

@export var name : String
@export var statDict = {} #Stat.type : Stat
@export var skillDict = {} #id : skill

func _init(name_ : String, data : Dictionary = {}):
	name = name_
	if data.is_empty():
		statDict = {
			Stat.T.hp : Stat.new(100), 
			Stat.T.atk : Stat.new(10), 
			Stat.T.def : Stat.new(10),
			Stat.T.agi : Stat.new(10),
			Stat.T.regen : Stat.new(5),
			Stat.T.vampire : Stat.new(0),
			Stat.T.revival : Stat.new(0),
			Stat.T.threat : Stat.new(0),
			Stat.T.ignoreDef : Stat.new(0),
			Stat.T.reflectAtk : Stat.new(0)
		}
	else:
		statDict = {}
	skillDict = {}

func getStatValue(type : Stat.T) -> int:
	return statDict[type].getValue()

func addModToStat(id: int, mod : StatMod):
	statDict[mod.stype].addModifier(id,mod)

func removeModfromStat(id: int, mod : StatMod):
	statDict[mod.stype].removeModifier(id)

func addSkill(s : Skill):
	skillDict[s.id] = s

func removeSkill(s : Skill):
	skillDict.erase(s.id)
