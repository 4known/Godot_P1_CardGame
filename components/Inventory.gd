extends Node
class_name Inventory

var inventory : Dictionary = {} #id int : amount
var team : Array[Entity] = []
var entities : Array[Entity] = []

func addToInventory(id : int, amount : int):
	if inventory.has(id):
		inventory[id] += amount
	else:
		inventory[id] = amount

func removeFromInventory(id : int, amount : int):
	if inventory.has(id):
		inventory[id] -= amount
		if inventory[id] <= 0:
			inventory.erase(id)
	else:
		print("No item")
