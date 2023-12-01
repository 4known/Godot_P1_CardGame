@tool
extends Control
class_name CardPanel

@export var cardRes : CardBase
@export var property : VBoxContainer
@export var name_ : LineEdit

const enumValue = preload("res://addons/CardEditor/PropertyBoxes/EnumValue.tscn")
const statmod = preload("res://addons/CardEditor/PropertyBoxes/StatMod.tscn")

func loadPanel():
	if cardRes.get_script()  == ActiveSkill:
		ActiveSkillCard()


func saveCard():
	ResourceSaver.save(cardRes, cardRes.resource_path)

func ActiveSkillCard():
	for m in cardRes.statModArr:
		var newbox = statmod.instantiate()
		property.add_child(newbox)
		newbox.get_child(0).value = m.value

		var a = newbox.get_child(1) as OptionButton
		for t in Stat.T:
			a.add_item(t)
		var b = newbox.get_child(2) as OptionButton
		for t in StatMod.T:
			b.add_item(t)
