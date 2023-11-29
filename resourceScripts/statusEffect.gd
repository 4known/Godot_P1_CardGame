extends CardBase
class_name StatusEffect

@export var turn : float
@export var statMod : StatMod
@export var tier : int

func _init(_turn : float, _statMod : StatMod, _tier : int):
	turn = _turn
	tier = _tier
	statMod = _statMod
