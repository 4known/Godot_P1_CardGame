extends Node
class_name GameState

@onready var players = $"../Players"
@onready var enemies = $"../Enemies"
@onready var ter = $"../Terrain"
@onready var turnM = $"../TurnManager"

const card = preload("res://Scene/card.tscn")

var enemynum : int = 1
var playernum : int = 5

enum states{GameLoad, PlayerTurn, EntityTurn, NextRoom, GoToRoom, ArrivedAtRoom}
var currentState : states = states.GameLoad
var turnNum: int = 0
signal newTurn

var next : bool = true
func _input(event):
	if event.is_action_pressed("1") and next:
		updateState()

func n():
	next = true

func updateState():
	turnNum += 1
	print("Turn: " + str(turnNum))
	match currentState:
		states.GameLoad:
			print("LoadGame")
			currentState = states.PlayerTurn
			loadGame()
		states.PlayerTurn:
			print("PlayerTurn")
			if players.get_child_count() == 0:
				print("Game Over")
				return
			emit_signal("newTurn", currentState)
			playerTurn(false)
			next = false
			currentState = states.EntityTurn
		states.EntityTurn:
			print("EntityTurn")
			if enemies.get_child_count() == 0:
				currentState = states.NextRoom
				return
			emit_signal("newTurn", currentState)
			entityTurn()
			next = false
			currentState = states.PlayerTurn
		states.NextRoom:
			print("NextRoom")
			ter.nextRoom()
			spawnEnemy()
			currentState = states.GoToRoom
		states.GoToRoom:
			print("GoToRoom")
			emit_signal("newTurn", currentState)
			playerTurn(true)
			next = false
			currentState = states.ArrivedAtRoom
		states.ArrivedAtRoom:
			print("ArrivedAtRoom")
			ter.removePreviousRoomPF()
			currentState = states.PlayerTurn

func loadGame():
	#Terrain Generation
	ter.initGeneration()
	spawnEnemy()
	spawnPlayer()

func playerTurn(onlyPath : bool):
	for p in players.get_children():
		p.onlyPath = onlyPath
		p.myTurn()
	turnM.processPathRequest()

func entityTurn():
	for e in enemies.get_children():
		e.onlyPath = false
		e.myTurn()
	turnM.processPathRequest()

func spawnPlayer():
	for i in SaveManager.entities.keys():
		var pos : Vector2i = ter.pickInsideRadius(ter.currentRoom)
		while ter.pf.IsOccupied(pos):
			pos = ter.pickInsideRadius(ter.currentRoom)
		var newCard = initilizeCard(ter.map_to_local(pos), Card.types.player)
		newCard.name = i
		players.add_child(newCard)

func spawnEnemy():
	var i = 1
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
