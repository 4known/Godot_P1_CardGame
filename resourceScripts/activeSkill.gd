extends Skill
class_name ActiveSkill

func _init():
	type = Skill.t.Active

func getDamage(baseAtk : int) -> int:
	var damage : int = baseAtk
	if type == t.Active:
		if statMod.mtype == StatMod.t.flat:
			damage += statMod.value
		elif statMod.mtype == StatMod.t.percent:
			damage += round(baseAtk * statMod.value * 0.01)
	return damage
