extends Node
class_name EntityStatus

var maxHp : int = 100
var hp : int = 100

func _ready():
	$"../Healthbar".max_value = maxHp
	$"../Healthbar".value = hp

func updateHealth(value):
	if(hp + value > maxHp):
		hp = maxHp
	elif (hp + value <= 0):
		hp = 0
		get_parent().destorySelf()
	else:
		hp += value
	$"../Healthbar".max_value = maxHp
	$"../Healthbar".value = hp

func getHp() -> int:
	return hp
