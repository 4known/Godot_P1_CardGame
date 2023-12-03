extends Node
class_name EntityStat

var statDict = {} #Stat.type : Stat

func _ready():
	initStat()

func initStat():
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

func getStatValue(type : Stat.T) -> int:
	return statDict[type].getValue()

func addModToStat(id: int, mod : StatMod):
	statDict[mod.stype].addModifier(id,mod)

func removeModfromStat(id: int, mod : StatMod):
	statDict[mod.stype].removeModifier(id)
