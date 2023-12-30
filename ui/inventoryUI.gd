extends Panel

@onready var closeBTN : Button = $CloseBTN
@onready var addBTN : Button = $AddBTN
@onready var teams : FlowContainer = $Scroll/Vertical/Team
@onready var entities : FlowContainer = $Scroll/Vertical/Entity
@onready var items : FlowContainer = $Scroll/Vertical/Item

const slot = preload("res://ui/slots.tscn")

func _ready():
	#displayItem()
	#displayEntity()
	#displayTeam()
	addBTN.pressed.connect(newEntity)

func displayTeam():
	for team in SaveManager.inventoryData.team:
		var newSlot = slot.instantiate()
		teams.add_child(newSlot)
		newSlot.text = team.name

func displayEntity():
	for entity in SaveManager.inventoryData.entities:
		var newSlot = slot.instantiate()
		entities.add_child(newSlot)
		newSlot.text = entity.name

func displayItem():
	for item in SaveManager.inventoryData.inventory.keys():
		var newSlot = slot.instantiate()
		items.add_child(newSlot)
		newSlot.text = item

func newEntity():
	SaveManager.inventoryData.createNewEntity()
	displayEntity()
