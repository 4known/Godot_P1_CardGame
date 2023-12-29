extends Control

@onready var invBTN : Button = $InvBTN
@onready var inv : Panel = $Inventory

var inventoryData : Inventory

func _ready():
	inv.visible = false
	invBTN.pressed.connect(openInventory)
	inv.closeBTN.pressed.connect(closeInventory)

func loadInventory():
	if !ResourceLoader.exists("user://save/inventory"):
		inventoryData = Inventory.new()
		ResourceSaver.save(inventoryData, "user://save/inventory")
	else:
		inventoryData = ResourceLoader.load("user://save/inventory")
func openInventory():
	inv.visible = true
func closeInventory():
	inv.visible = false
