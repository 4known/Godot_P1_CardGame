extends Panel

@onready var closeBTN : Button = $CloseBTN
@onready var addBTN : Button = $AddBTN
@onready var entityName : LineEdit = $EntityName
@onready var entityContainer : FlowContainer = $Scroll/Vertical/Entity
@onready var itemsContainer : FlowContainer = $Scroll/Vertical/Item

const slot = preload("res://ui/slots.tscn")

var entityDisplay : Array[String] = []
var itemsDisplay : Array[int] = []

func _ready():
	displayItem()
	displayEntity()
	addBTN.pressed.connect(newEntity)

func displayEntity():
	for entity in SaveManager.entities.keys():
		var newSlot = slot.instantiate()
		if !entityDisplay.has(entity):
			entityContainer.add_child(newSlot)
		entityDisplay.append(entity)
		newSlot.text = entity

func displayItem():
	for item in SaveManager.items.keys():
		var newSlot = slot.instantiate()
		if !itemsDisplay.has(item):
			itemsContainer.add_child(newSlot)
		itemsDisplay.append(item)
		newSlot.text = item

func newEntity():
	SaveManager.addToEntities(Entity.new(entityName.text))
	SaveManager.saveEntities()
	displayEntity()
