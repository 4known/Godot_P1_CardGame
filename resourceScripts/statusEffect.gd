extends CardBase
class_name StatusEffect

@export var statMod : StatMod
@export var attribute : Skill.A
@export var tier : int

func _init(_statMod : StatMod, _tier : int):
	tier = _tier
	statMod = _statMod
