extends CardBase
class_name StatusEffect

@export var statMod : StatMod
@export var tier : int
@export var buff : bool

func _init(_statMod : StatMod, _tier : int):
	tier = _tier
	statMod = _statMod
