extends Node

const inventoryPath = "user://saves/inventory.dat"
var inventoryData : Inventory

func loadInventory():
	var file = FileAccess.open(inventoryPath, FileAccess.WRITE_READ)
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		return
	return inventoryData

func saveInventory():
	var file = FileAccess.open(inventoryPath, FileAccess.WRITE)
