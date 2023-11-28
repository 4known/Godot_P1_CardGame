extends Resource

class_name StatMod

@export var value : int
@export var stype: Stat.t
@export var mtype : t

enum t{flat,percent}

func _init(_value : int = 10, statType : Stat.t = Stat.t.hp, modtype : t = t.flat):
	value = _value
	stype = statType
	mtype = modtype
