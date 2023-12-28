extends CardBase
class_name Skill

@export var statModArr : Array[StatMod]

@export var coolDown : int
@export var range_ : int

@export var type : T
enum T{Passive,Active,PassivelyActive}

func _init():
	statModArr = [StatMod.new(10,Stat.T.atk,StatMod.T.flat)]
	coolDown = 3
	range_ = 4
