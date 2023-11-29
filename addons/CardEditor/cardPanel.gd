@tool
extends Control
class_name CardPanel

@export var cardRes : CardBase

@export var stats : HBoxContainer

func _ready():
	if cardRes.get_script() == Skill:
		print("s")


func saveCard():
	ResourceSaver.save(cardRes, cardRes.resource_path)
