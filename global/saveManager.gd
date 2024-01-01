extends Node
const itemsPath = "user://items.dat"
const entitiesPath = "user://entities.dat"
const resourcePath = "res://JsonFiles/ResourceDatas.json"

var resources : Dictionary = {}
var items : Dictionary = {} #ID : Amount
var entities : Dictionary = {} #Name : EntityData in string

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
		print("Resourceerror") 
		return
	resources = json.data

func loadItems():
	if FileAccess.file_exists(itemsPath):
		var file = FileAccess.open(itemsPath, FileAccess.READ)
		var content = file.get_var()
		file.close()
		items = content
	else:
		var file = FileAccess.open(itemsPath, FileAccess.WRITE)
		items = {}
		file.store_var(items)
		file.close()
	print("ItemSize: " + str(items.size()))

func loadEntities():
	if FileAccess.file_exists(entitiesPath):
		var file = FileAccess.open(entitiesPath, FileAccess.READ)
		var content = file.get_var()
		file.close()
		entities = content
	else:
		var file = FileAccess.open(entitiesPath, FileAccess.WRITE)
		entities = {}
		file.store_var(entities)
		file.close()
	print("Entities: " + str(entities.size()))

func saveItems():
	var file = FileAccess.open(itemsPath, FileAccess.WRITE)
	file.store_var(items)
	file.close()

func saveEntities():
	var file = FileAccess.open(entitiesPath, FileAccess.WRITE)
	file.store_var(entities)
	file.close()

func addToItems(id : String, amount : int):
	if items.has(id):
		items[id] += amount
	else:
		items[id] = amount
func removeFromItems(id : String, amount : int):
	if items.has(id):
		items[id] -= amount
		if items[id] <= 0:
			items.erase(id)
	else:
		print("No item")

func addToEntities(entity : Entity):
	entities[entity.name] = entityToString(entity)
func removeFromEntities(name : String):
	entities.erase(name)

func entityToString(entity : Entity) -> Dictionary:
	var entityStr = {"statDict": {},"skillDict": []}
	for stat in entity.statDict.keys():
		entityStr["statDict"][str(stat)] = statToString(entity.statDict[stat])
	for id in entity.skillDict.keys():
		entityStr["skillDict"].append(id)
	return entityStr

func statToString(stat : Stat) -> Dictionary:
	var statStr = {"BaseValue": stat.basevalue, "StatModDict" : []}
	for mod in stat.statModDict.keys():
		statStr["StatModDict"].append(mod)
	return statStr

func stringToStat(statStr : Dictionary) -> Stat:
	var stat := Stat.new(statStr["BaseValue"])
	
	return stat
