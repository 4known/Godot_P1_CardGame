extends Panel

@onready var closeBTN : Button = $CloseBTN
@onready var addBTN : Button = $AddBTN
@onready var teams : FlowContainer = $Scroll/Vertical/Team
@onready var entities : FlowContainer = $Scroll/Vertical/Entity
@onready var items : FlowContainer = $Scroll/Vertical/Item

var inventoryData : Inventory
const slot = preload("res://ui/slots.tscn")

func _ready():
	get_parent().loadInventory()
	inventoryData = get_parent().inventoryData
	displayItem()
	displayEntity()
	displayTeam()
	addBTN.pressed.connect(newEntity)

func displayTeam():
	for team in inventoryData.team:
		var newSlot = slot.instantiate()
		teams.add_child(newSlot)
		newSlot.text = team.name

func displayEntity():
	for entity in inventoryData.entities:
		var newSlot = slot.instantiate()
		entities.add_child(newSlot)
		newSlot.text = entity.name

func displayItem():
	for item in inventoryData.inventory.keys():
		var newSlot = slot.instantiate()
		items.add_child(newSlot)
		newSlot.text = item

func newEntity():
	inventoryData.createNewEntity()
	ResourceSaver.save(inventoryData,"user://save/inventory")
	displayEntity()
