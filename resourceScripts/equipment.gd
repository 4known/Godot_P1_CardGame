extends ItemBase
class_name Equipment

@export var slot : t = t.helment
enum t{helment, chestplate, legging}

func _init():
	maxStack = 1
