extends Node
class_name Stat

var basevalue : int
var MAXVALUE: int

var statModDict = {} #index : StatModifier
var recalc = false

enum T{hp,atk,def,agi,regen,vampire,revival,threat,ignoreDef}

func _init(initialvalue : int):
	basevalue = initialvalue
	MAXVALUE = initialvalue
	statModDict.clear()

func getValue():
	if recalc:
		MAXVALUE = basevalue + modificationValue()
		recalc = false
	return MAXVALUE

func addModifier(index : int, mod : StatMod):
	if statModDict.has(index):
		statModDict[index] = mod
		recalc = true

func removeModifier(index : int):
	statModDict.erase(index)
	recalc = true

func modificationValue():
	var finalValue : int = 0
	if statModDict.size() > 0:
		for key in statModDict.keys():
			var mod = statModDict[key]
			if mod.mtype == StatMod.T.flat:
				finalValue += mod.value
			elif mod.mtype == StatMod.T.percent:
				finalValue += round(basevalue * mod.value * 0.01)
	return finalValue

func setBaseValue(value : int):
	basevalue = value
