extends Panel

@onready var closeBTN : Button = $CloseBTN
@onready var addBTN : Button = $AddBTN
@onready var entities : FlowContainer = $Scroll/Vertical/Entity
@onready var items : FlowContainer = $Scroll/Vertical/Item

const slot = preload("res://ui/slots.tscn")

func _ready():
	displayItem()
	displayEntity()
	addBTN.pressed.connect(newEntity)
	SaveManager.removeFromEntities("Hell")

func displayEntity():
	for entity in SaveManager.entities.keys():
		var newSlot = slot.instantiate()
		entities.add_child(newSlot)
		newSlot.text = entity

func displayItem():
	for item in SaveManager.items.keys():
		var newSlot = slot.instantiate()
		items.add_child(newSlot)
		newSlot.text = item

func newEntity():
	SaveManager.addToEntities(Entity.new("Hell"))
	print(SaveManager.entities["Hell"])
	SaveManager.saveEntities()
	displayEntity()
