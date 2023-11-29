extends CardBase
class_name Skill

@export var statModArr : Array[StatMod]
@export var statEftArr : Array[StatusEffect]

@export var coolDown : int
@export var range : int

@export var projectile : bool

@export var attribute : A
@export var attInt : int
enum A{none, vampire, revival, teamUp, ignoreDef}

@export var type : T
enum T{Passive,Active,PassivelyActive}

func _init():
	statModArr = [StatMod.new(10,Stat.T.atk,StatMod.T.flat)]
	coolDown = 3
	range = 4
	projectile = false
