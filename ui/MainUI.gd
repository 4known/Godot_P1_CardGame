extends Control

@onready var invBTN : Button = $HBoxContainer/InvBTN
@onready var inv : Panel = $Inventory

func _ready():
	inv.visible = false
	invBTN.pressed.connect(openInventory)
	inv.closeBTN.pressed.connect(closeInventory)

func openInventory():
	inv.visible = true
func closeInventory():
	inv.visible = false
