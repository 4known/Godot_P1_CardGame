extends Control

@onready var invBTN : Button = $InvBTN
@onready var inv : Panel = $Inventory

var inventoryData : Inventory

func _ready():
	inv.visible = false
	invBTN.pressed.connect(openInventory)
	inv.closeBTN.pressed.connect(closeInventory)

func openInventory():
	inv.visible = true
func closeInventory():
	inv.visible = false
