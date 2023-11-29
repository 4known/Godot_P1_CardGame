extends Resource

class_name StatMod

@export var value : int
@export var stype: Stat.T
@export var mtype : T

enum T{flat,percent}

func _init(_value : int = 10, statType : Stat.T = Stat.T.hp, modtype : T = T.flat):
	value = _value
	stype = statType
	mtype = modtype
