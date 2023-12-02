extends Node
class_name EntityStatus

@onready var healthBar : ProgressBar = $"../Healthbar"
var maxHp : int = 100
var hp : int = 100

var buff : Dictionary = {}
var debuff : Dictionary = {}

func _ready():
	healthBar.max_value = maxHp
	healthBar.value = hp

func updateHealth(value):
	if(hp + value > maxHp):
		hp = maxHp
	elif (hp + value <= 0):
		hp = 0
		get_parent().destorySelf()
	else:
		hp += value
	healthBar.max_value = maxHp
	healthBar.value = hp

func _on_card_turn():
	#Update StatusEffect
	pass

func addBuff(e : StatusEffectTurn):
	pass

func addDebuff(e : StatusEffectTurn):
	pass

func removeRanDebuff(num : int):
	pass

func removeRanBuff(num : int):
	pass

func removeAllDebuff():
	debuff.clear()

func removeAllBuff():
	buff.clear()

func getHp() -> int:
	return hp

class StatusEffectTurn:
	var statusEft : StatusEffect
	var turns : int
	
