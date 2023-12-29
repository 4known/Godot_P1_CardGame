extends Node

const inventoryPath = "user://saves/inventory.dat"

func loadInventory()-> Inventory:
	var inventoryData : Inventory
	if !FileAccess.file_exists(inventoryPath):
		inventoryData = Inventory.new()
		pass
	else:
		var file = FileAccess.open(inventoryPath, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		var error = json.parse(content)
		if error != OK:
			return
	return inventoryData

func saveInventory():
	pass
