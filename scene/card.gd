extends Area2D
class_name Card

@onready var stat = $EntityStat
@onready var status = $EntityStatus
@onready var skill = $EntitySkill

var type : types
enum types{player,enemy}

#Path
var currentPath : Array[Vector2i]
var ter : Terrain
var move : bool = false
#Turn
signal turn
var onlyPath : bool = false

#func _ready():
#	$Label.text = name

func _process(_delta):
	followPath()

func myTurn():
	turn.emit()
	Signals.emit_signal("requestTurn", self)

func followPath():
	if !move: return
	if currentPath.is_empty():
		if !onlyPath:
			Signals.emit_signal("arrivedNowAttack")
		move = false
		return
	var movepos = ter.map_to_local(currentPath.front())
	if global_position != movepos:
		global_position = global_position.move_toward(movepos,2)
		if global_position == movepos:
			currentPath.pop_front()
	else:
		currentPath.pop_front()

func destorySelf():
	queue_free()

func _on_input_event(_viewport, _event, _shape_idx):
	if _event is InputEventMouseButton and _event.pressed:
		Signals.emit_signal("displayStat", self)
		_viewport.set_input_as_handled()

#Setter/Getter
func setTerrain(t : Terrain):
	ter = t
func setPath(paths : Array[Vector2i]):
	currentPath = paths
	move = true
func setType(type_ : types):
	type = type_
func getStat() -> EntityStat:
	return stat
func getStatus()-> EntityStatus:
	return status
func getSkill() -> EntitySkill:
	return skill
func getSpritePos()-> Vector2:
	return get_child(0).global_position




