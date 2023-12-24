extends Node
class_name GameState

@onready var players = $"../Players"
@onready var enemies = $"../Enemies"
@onready var ter = $"../Terrain"
@onready var turnM = $"../TurnManager"

const card = preload("res://Scene/card.tscn")

var enemynum : int = 1
var playernum : int = 10
var spawnpos : Array[Vector2i] = []

enum states{GameLoad, PlayerTurn, EntityTurn}
var currentState : states = states.GameLoad
var turnNum: int = 0
signal newTurn

var next : bool = true
func _input(event):
	if event.is_action_pressed("1") and next:
		updateState()
	if event.is_action_pressed("2"):
		ter.generateTerrain()

func n():
	next = true

func updateState():
	turnNum += 1
	print("Turn: " + str(turnNum))
	match currentState:
		states.GameLoad:
			loadGame()
			currentState = states.PlayerTurn
		states.PlayerTurn:
			print("PlayerTurn")
			emit_signal("newTurn", currentState)
			playerTurn()
			next = false
			currentState = states.EntityTurn
		states.EntityTurn:
			print("EntityTurn")
			emit_signal("newTurn", currentState)
			entityTurn()
			next = false
			currentState = states.PlayerTurn

func loadGame():
	#Terrain Generation
	ter.initGeneration()
	spawnEnemy()
	#spawnPlayer()
	#updateState()

func playerTurn():
	for p in players.get_children():
		p.myTurn()

func entityTurn():
	for e in enemies.get_children():
		e.myTurn()

func spawnPlayer():
	for i in range(playernum):
		var pos : Vector2i
		while spawnpos.has(pos) or ter.get_cell_source_id(0,ter.local_to_map(pos)) == -1:
			pos = ter.map_to_local(Vector2i(randi_range(-5,5),randi_range(-5,5)))
		spawnpos.append(pos)
		ter.pf.SetNodeOccupied(ter.local_to_map(pos),true)
		var newCard = initilizeCard(pos, Card.types.player)
		newCard.name = "Player" + str(i)
		players.add_child(newCard)

func spawnEnemy():
	var i = 0
	for pos in ter.currentRoom.enemiesPosition:
		var newCard = initilizeCard(ter.map_to_local(pos), Card.types.enemy)
		newCard.name = "Enemy" + str(i)
		enemies.add_child(newCard)
		i += 1

func initilizeCard(pos : Vector2i, type : Card.types) -> Card:
	var newCard = card.instantiate()
	newCard.global_position = pos
	newCard.setType(type)
	newCard.setTerrain(ter)
	return newCard
