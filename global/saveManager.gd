
const itemsPath = "user://items.dat"
const entitiesPath = "user://entities.dat"
const teamPath = "user://team.dat"

var items : Dictionary #
var entities : Dictionary
var maxTeamSize : int = 5
var team : Dictionary

func _ready():
	loadItems()
	loadEntities()
	loadTeam()

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
		items = content
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
		entities = content
	else:
		var file = FileAccess.open(entitiesPath, FileAccess.WRITE)
		entities = {}
		file.store_var(entities)
		file.close()

func loadTeam():
	if FileAccess.file_exists(teamPath):
		var file = FileAccess.open(teamPath, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		var error = json.parse(content)
		if error != OK:
			print(error) 
			return
		team = content
	else:
		var file = FileAccess.open(teamPath, FileAccess.WRITE)
		team = {}
		file.store_var(team)
		file.close()

func save():
	var file = FileAccess.open(itemsPath, FileAccess.WRITE)
	file.store_var(items)
	file.close()
	file = FileAccess.open(entitiesPath, FileAccess.WRITE)
	file.store_var(entities)
	file.close()
	file = FileAccess.open(teamPath, FileAccess.WRITE)
	file.store_var(team)
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

func addToTeam(entity : Entity):
	if team.size() <= maxTeamSize:
		team[entity.name] = entity
func removeFromTeam(entity : Entity):
	team.erase(entity)

func addToEntities(entity : Entity):
	entities[entity.name] = entity
func removeFromEntities(entity : Entity):
	entities.erase(entity)

func createNewEntity():
	addToEntities(Entity.new())

func entityToString(entity : Entity):
	var entityStr = {"Name": entity.name}
	entityStr["statDict"] = entity.statDict
