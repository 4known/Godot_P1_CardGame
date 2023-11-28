extends CardBase
class_name StatusEffect

@export var time : float
@export var statMod : StatMod
@export var tier : int

func _init(_time : float, _statMod : StatMod, _tier : int):
	time = _time;
	tier = _tier
	statMod = _statMod
