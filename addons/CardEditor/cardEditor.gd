@tool
extends EditorPlugin

const Screen = preload("res://addons/CardEditor/cardEditorMain.tscn")
var screen

#UI
var refreshBTN : Button
var createBTN : Button
var type : OptionButton
var contents : FlowContainer
#Resources
var folder : String = "res://resources/"

#CardPanel
const entityPanel = preload("res://addons/CardEditor/cardPanel.tscn")
var cardDict : Dictionary = {}

func _enter_tree():
	screen = Screen.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(screen)
	_make_visible(false)
	setButtons()
	setCallBacks()
	refresh()

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
	createBTN = screen.get_node("Tool/HBoxContainer/Create")
	type = screen.get_node("Tool/HBoxContainer/ResourceType")
	contents = screen.get_node("ScrollContainer/Content")

func setCallBacks():
	if createBTN: 
		createBTN.pressed.connect(self.createCard)
	if refreshBTN:
		refreshBTN.pressed.connect(self.refresh)

func clearCallBacks():
	if createBTN: 
		createBTN.pressed.disconnect(self.createCard)
	if refreshBTN: 
		refreshBTN.pressed.disconnect(self.refresh)

func createCard():
	var newCard : Entity = Entity.new()
	var savePath = folder + str(newCard.get_instance_id()) + ".tres"
	ResourceSaver.save(newCard, savePath)
	cardDict[newCard.id] = newCard
	createCardPanel(newCard)

func deleteCard(card : CardBase):
	if !card : return
	cardDict.erase(card)
	refreshFiles()

func createCardPanel(card : CardBase):
	var newPanel = entityPanel.instantiate()
	contents.add_child(newPanel)
	#contents setup card data

func refresh():
	print("refresh")
	clearContent()
	var dir = DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var card = ResourceLoader.load(file_name)
			print(file_name)
			createCardPanel(card)
			file_name = dir.get_next()

func clearContent():
	for c in contents.get_children():
		contents.remove_child(c)
		c.queue_free()
	cardDict.clear()

func refreshFiles():
	get_editor_interface().get_resource_filesystem().scan()
