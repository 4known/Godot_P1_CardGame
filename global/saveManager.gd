extends Node
const itemsPath = "user://items.json"
const entitiesPath = "user://entities.json"
const resourcePath = "res://JsonFiles/ResourceDatas.json"

var resources : Dictionary = {}
var items : Dictionary = {} #ID : Amount
var entities : Dictionary = {} #Name : EntityData in Dictionary

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
	entities[entity.name] = entityToData(entity)
func removeFromEntities(name : String):
	entities.erase(name)

func entityToData(entity : Entity) -> Dictionary:
	var entityData = {"statDict": {},"skillDict": []}
	for stat in entity.statDict.keys():
		entityData["statDict"][str(stat)] = statToData(entity.statDict[stat])
	for id in entity.skillDict.keys():
		entityData["skillDict"].append(id)
	return entityData

func dataToEntity(entityData : Dictionary, entityName : String) -> Entity:
	var entity := Entity.new(entityName)
	for stat in entityData["statDict"].keys():
		entity.statDict[Stat.T[stat]] = dataToStat(entityData["statDict"][stat])
	for skill in entityData["skillDict"]:
		entity.skillDict[skill] = dataToActiveSkill(resources[skill], skill)
	return entity

func statToData(stat : Stat) -> Dictionary:
	var statData = {"BaseValue": stat.basevalue, "StatModDict" : []}
	for mod in stat.statModDict.keys():
		statData["StatModDict"].append(mod)
	return statData

func dataToStat(statData : Dictionary) -> Stat:
	var stat := Stat.new(statData["BaseValue"])
	for mod in statData["StatModDict"]:
		if resources[mod]["CardType"] == "ActiveSkill":
			var skillEftArr = resources[mod]["SkillEftArray"]
			stat.addModifier(mod,resources[skillEftArr["StatusEffect"]]["StatModArray"][skillEftArr["Tier"]])
	return stat

func dataToActiveSkill(skillData : Dictionary, skillName : String) -> ActiveSkill:
	var skill := ActiveSkill.new()
	skill.name = skillName
	skill.type = Skill.T.get(skillData["Type"])
	skill.range_ = skillData["Range"]
	skill.coolDown = skillData["CD"]
	for mod in skillData["StatModArray"]:
		var statmod = StatMod.new(mod["Value"])
		statmod.stype = Stat.T.get(mod["Stype"])
		statmod.mtype = StatMod.T.get(mod["Mtype"])
		skill.statModArr.append(statmod)
	skill.projectile = skillData["Projectile"]
	for eft in skillData["SkillEftArray"]:
		var skilleffect = SkillEffect.new()
		skilleffect.statusEffect = dataToStatusEffect(resources[eft["StatusEffect"]], eft["StatusEffect"])
		skilleffect.tier = eft["Tier"]
		skilleffect.turns = eft["Turn"]
		skilleffect.chance = eft["Chance"]
		skill.skillEftArr.append(skilleffect)
	return skill

func dataToStatusEffect(effectData : Dictionary, effectName : String) -> StatusEffect:
	var statusEffect = StatusEffect.new()
	statusEffect.name = effectName
	statusEffect.type = Stat.T.get(effectData["Type"])
	for mod in effectData["StatModArray"]:
		var statmod = StatMod.new(mod["Value"])
		statmod.stype = Stat.T.get(mod["Stype"])
		statmod.mtype = StatMod.T.get(mod["Mtype"])
		statusEffect.statModArr.append(statmod)
	return statusEffect
