extends Control

@onready var invBTN : Button = $InvBTN
@onready var inv : Panel = $Inventory

func _ready():
	inv.visible = false
	invBTN.pressed.connect(openInventory())


func openInventory():
	inv.visible = true
func closeInventory():
	inv.visible = false
