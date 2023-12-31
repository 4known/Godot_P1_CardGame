@tool
extends EditorPlugin

const Screen = preload("res://addons/CardEditor/cardEditorMain.tscn")
var screen

#UI
var refreshBTN : Button
var createBTN : Button
var readBTN : Button
var type : OptionButton
var contents : FlowContainer
#Resources
var folder : String = "res://resources/"

#CardPanel
const cardPanel = preload("res://addons/CardEditor/cardPanel.tscn")
var cardDict : Dictionary = {} #ID:Card

func _enter_tree():
	screen = Screen.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(screen)
	_make_visible(false)
	setButtons()
	setCallBacks()

func _exit_tree():
	if screen:
		screen.queue_free()
	clearCallBacks()
	pass

func _make_visible(visible):
	if screen:
		screen.visible = visible

func _has_main_screen():
	return true

func _get_plugin_name():
	return "Card Editor"

func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")

func setButtons():
	refreshBTN = screen.get_node("Tool/HBoxContainer/Refresh")
	readBTN = screen.get_node("Tool/HBoxContainer/ReadFile")
	type = screen.get_node("Tool/HBoxContainer/ResourceType")
	contents = screen.get_node("ScrollContainer/Content")

func setCallBacks():
	if refreshBTN:
		refreshBTN.pressed.connect(self.refresh)
	if readBTN:
		readBTN.pressed.connect(self.readFile)

func clearCallBacks():
	if refreshBTN: 
		refreshBTN.pressed.disconnect(self.refresh)
	if readBTN:
		readBTN.pressed.disconnect(self.readFile)

func createCardPanel(card : CardBase):
	var newPanel = cardPanel.instantiate()
	contents.add_child(newPanel)
	newPanel.cardRes = card
	newPanel.loadPanel()

func refresh():
	clearContent()
	var dir = DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "": 
			if file_name.ends_with(".tres"):
				var card = ResourceLoader.load(folder+file_name)
				cardDict[card.id] = card
				createCardPanel(card)
			file_name = dir.get_next()
		dir.list_dir_end()

func clearContent():
	for c in contents.get_children():
		contents.remove_child(c)
		c.queue_free()
	cardDict.clear()

func refreshFiles():
	get_editor_interface().get_resource_filesystem().scan()

func readFile():
	clearDirectory()
	var file = FileAccess.open("res://JsonFiles/ResourceDatas.json", FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		return
	for data in json.data:
		match data["CardType"]:
			"ActiveSkill":
				createActiveSkill(data)
			"StatusEffect":
				createStatusEffect(data)

func createActiveSkill(data):
	var newCard = ActiveSkill.new()
	var savePath = folder + str(data["Name"] + ".tres")
	newCard.id = data["ID"]
	newCard.type = Skill.T.get(data["Type"])
	newCard.range_ = data["Range"]
	newCard.coolDown = data["CD"]
	for mod in data["StatModArray"]:
		var statmod = StatMod.new(mod["Value"])
		statmod.stype = Stat.T.get(mod["Stype"])
		statmod.mtype = StatMod.T.get(mod["Mtype"])
		newCard.statModArr.append(statmod)
	newCard.projectile = data["Projectile"]
	for eft in data["SkillEftArray"]:
		var skilleffect = SkillEffect.new()
		skilleffect.statusEffect = cardDict[int(eft["StatusEffect"])]
		skilleffect.tier = eft["Tier"]
		skilleffect.turns = eft["Turn"]
		skilleffect.chance = eft["Chance"]
		newCard.skillEftArr.append(skilleffect)
	cardDict[newCard.id] = newCard
	ResourceSaver.save(newCard, savePath)

func createStatusEffect(data):
	var newCard = StatusEffect.new()
	var savePath = folder + str(data["Name"] + ".tres")
	newCard.id = data["ID"]
	newCard.type = Stat.T.get(data["Type"])
	for mod in data["StatModArray"]:
		var statmod = StatMod.new(mod["Value"])
		statmod.stype = Stat.T.get(mod["Stype"])
		statmod.mtype = StatMod.T.get(mod["Mtype"])
		newCard.statModArr.append(statmod)
	cardDict[newCard.id] = newCard
	ResourceSaver.save(newCard, savePath)

func clearDirectory():
	cardDict.clear()
	var dir = DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			dir.remove_absolute(folder+file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
