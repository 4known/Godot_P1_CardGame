extends Node
class_name GameState

@onready var players = $"../Players"
@onready var enemies = $"../Enemies"
@onready var ter = $"../Terrain"
@onready var turnM = $"../TurnManager"

const card = preload("res://Scene/card.tscn")

var enemynum : int = 1
var playernum : int = 5
var spawnpos : Array[Vector2i] = []

enum states{GameLoad, PlayerTurn, EntityTurn}
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
			currentState = states.PlayerTurn
			loadGame()
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
	spawnPlayer()
	spawnEnemy()
	updateState()

func playerTurn():
	ter.clearDestination()
	setDestination()
	for p in players.get_children():
		p.myTurn()

func entityTurn():
	ter.clearDestination()
	setDestination()
	for e in enemies.get_children():
		e.myTurn()

func setDestination():
	for p in players.get_children():
		ter.addDestination(p.global_position, false)
	for e in enemies.get_children():
		ter.addDestination(e.global_position, false)

func spawnPlayer():
	for i in range(playernum):
		var pos : Vector2i = ter.map_to_local(Vector2i(randi_range(-3,3),randi_range(-3,3)))
		while spawnpos.has(pos):
			pos = ter.map_to_local(Vector2i(randi_range(-3,3),randi_range(-3,3)))
		spawnpos.append(pos)
		var newCard = initilizeCard(pos, Card.types.player)
		newCard.name = "Player" + str(i)
		players.add_child(newCard)

func spawnEnemy():
	if players.get_child_count() == 0: return
	for i in range(enemynum):
		var playerpos : Vector2i = ter.local_to_map(players.get_child(0).global_position)
		var pos: Vector2i = ter.map_to_local(Vector2i(randi_range(-5,5) + playerpos.x,
				randi_range(-5,5)+ playerpos.y))
		while spawnpos.has(pos) and ter.astargrid.is_in_boundsv(ter.local_to_map(pos)):
			pos = ter.map_to_local(Vector2i(randi_range(-5,5) + playerpos.x,
				randi_range(-5,5)+ playerpos.y))
		spawnpos.append(pos)
		var newCard = initilizeCard(pos, Card.types.enemy)
		newCard.name = "Enemy" + str(i)
		enemies.add_child(newCard)

func initilizeCard(pos : Vector2i, type : Card.types) -> Card:
	var newCard = card.instantiate()
	newCard.global_position = pos
	newCard.setType(type)
	newCard.setTerrain(ter)
	return newCard
