extends CardBase
class_name Skill

@export var statMod : StatMod
@export var range_ : int
@export var projectile : bool
@export var type : t
enum t{Passive,Active,PassivelyActive}

func _init(range__ : int = 4, projectile_ : bool = false, type_ : t = t.Active):
	statMod = StatMod.new(10,Stat.t.atk,StatMod.t.flat)
	range_ = range__
	projectile = projectile_
	type = type_
