extends Resource
class_name StatModList

@export var modArray : Array[StatMod]

func _init(value : int = 10, statType : Stat.t = Stat.t.hp, modType : StatMod.t = StatMod.t.flat):
	var newMod := StatMod.new(value,statType,modType)
	modArray.append(newMod)
