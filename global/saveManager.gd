
const itemsPath = "user://items.dat"
const entitiesPath = "user://entities.dat"
const resourcePath = "res://JsonFiles/ResourceDatas.json"

var resources : Array
var items : Dictionary #ID : Amount
var entities : Dictionary #Name

func _ready():
	loadResources()
	loadItems()
	loadEntities()

func loadResources():
	var file = FileAccess.open(resourcePath, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		print(error) 
		return
	resources = json.data

func loadItems():
	if FileAccess.file_exists(itemsPath):
		var file = FileAccess.open(itemsPath, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		var error = json.parse(content)
		if error != OK:
			print(error) 
			return
		items = json.data
	else:
		var file = FileAccess.open(itemsPath, FileAccess.WRITE)
		items = {}
		file.store_var(items)
		file.close()

func loadEntities():
	if FileAccess.file_exists(entitiesPath):
		var file = FileAccess.open(entitiesPath, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		var error = json.parse(content)
		if error != OK:
			print(error) 
			return
		entities = json.data
	else:
		var file = FileAccess.open(entitiesPath, FileAccess.WRITE)
		entities = {}
		file.store_var(entities)
		file.close()

func save():
	var file = FileAccess.open(itemsPath, FileAccess.WRITE)
	file.store_var(items)
	file.close()
	file = FileAccess.open(entitiesPath, FileAccess.WRITE)
	file.store_var(entities)
	file.close()

func addToItems(id : int, amount : int):
	if items.has(id):
		items[id] += amount
	else:
		items[id] = amount
func removeFromItems(id : int, amount : int):
	if items.has(id):
		items[id] -= amount
		if items[id] <= 0:
			items.erase(id)
	else:
		print("No item")

func addToEntities(entity : Entity):
	entities[entity.name] = entityToString(entity)
func removeFromEntities(entity : Entity):
	entities.erase(entity.name)

func entityToString(entity : Entity):
	var entityStr = {"statDict": {},"skillDict": []}
	for stat in entity.statDict.keys():
		entityStr["statDict"][str(stat)] = entity.statDict[stat]
	for id in entity.skillDict.keys():
		entityStr["skillDict"].append(id)

