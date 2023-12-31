extends Resource
class_name Inventory

var inventory : Dictionary #id int : amount
var maxteamsize : int = 5
var team : Array[Entity]
var entities : Array[Entity]

func _init():
	inventory = {}
	team = []
	entities = []

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

func addToTeam(entity : Entity):
	if team.size() <= maxteamsize:
		team.append(entity)
func removeFromTeam(entity : Entity):
	team.erase(entity)

func addToEntities(entity : Entity):
	entities.append(entity)
func removeFromEntities(entity : Entity):
	entities.erase(entity)

