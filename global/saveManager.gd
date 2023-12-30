extends Node

const inventoryPath = "user://inventory.dat"
var item
var entities
var team

func _ready():
	loadInventory()

func loadInventory():
	if FileAccess.file_exists(inventoryPath):
		var file = FileAccess.open(inventoryPath, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		var error = json.parse(content)
		if error != OK:
			print(error) 
			return
		item = content
	else:
		var file = FileAccess.open(inventoryPath, FileAccess.WRITE)
		item = []
		file.store_var(item)
		file.close()

func saveInventory():
	var file = FileAccess.open(inventoryPath, FileAccess.WRITE)
	file.store_var(item)
	file.close()
