extends Skill
class_name ActiveSkill

var statEffectChance : Array[int]

func _init():
	type = Skill.T.Active

func getDamage(baseAtk : int) -> int:
	var damage : int = baseAtk
	for s in statModArr:
		if s.stype == Stat.T.atk:
			if s.mtype == StatMod.T.flat:
				damage += s.value
			elif s.mtype == StatMod.T.percent:
				damage += round(baseAtk * s.value * 0.01)
			break
	return damage
