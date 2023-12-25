extends Node
class_name TurnManager

@onready var ter = $"../Terrain"
@onready var gState = $"../GameState"
#Manager
var requestQueuePath : Array[Turn] = []
var requestQueueAtk : Array[Turn] = []
var reqPath : Turn = null
var reqAtk : Turn = null
var processingPath : bool = false
var processingAtk : bool = false
#Turn
var opponent : Dictionary = {} #Card : supposeHealthAfterDamage
var team : Array[Card] = []
#Projectile
const proj = preload("res://Scene/projectile.tscn")

func _ready():
	Signals.connect("requestTurn",requestTurn)
	Signals.connect("arrivedNowAttack", requestAttack)
	Signals.connect("projectileHitTarget", attackedTarget)

func requestTurn(card : Card):
	print("Add " + card.name + " to PathQueue")
	requestQueuePath.append(Turn.new(card))

func processPathRequest():
	print("Try process Path")
	if !processingPath and !requestQueuePath.is_empty():
		reqPath = requestQueuePath.pop_front()
		print("Processing Path for " + reqPath.card.name)
		processingPath = true
		findPath()

func findTarget():
	if opponent.is_empty():
		return
	var target : Card = null
	var minDistance : int
	for enemy in opponent:
		if target == null:
			target = enemy
			minDistance = ter.getDistance(reqPath.card.global_position,target.global_position)
			continue
		var distance = ter.getDistance(reqPath.card.global_position,enemy.global_position)
		if distance < minDistance:
			target = enemy
			minDistance = distance
	print(reqPath.card.name + " Target is " + target.name)
	reqPath.target = target
	var damage = 30 * -1
	reqPath.damage = damage
	print("Damage is " + str(damage))
	print("Target currentHP is " + str(opponent[target]))
	opponent[target] -= reqPath.target.getStatus().calculateDamage(damage*-1)
	print("Target supposeHP is " + str(opponent[target]))
	if opponent[target] <= 0:
		print("Target hp depleted")
		opponent.erase(reqPath.target)

func findPath():
	print("Find Target for " + reqPath.card.name)
	findTarget()
	var range_ = 4
	var cardpos = reqPath.card.global_position
	var targetp = reqPath.target.global_position
	var path = ter.getPath(cardpos,targetp,range_,true)
	print("Found path for " + reqPath.card.name)
	reqPath.card.setPath(path)
	processingPath = false
	pathRequestProcessed()

func pathRequestProcessed():
	print("Path processed for " + reqPath.card.name)
	if !requestQueuePath.is_empty():
		print("PathQueue not empty, process next")
		processPathRequest()

func requestAttack(card : Card):
	print("Add " + card.name + " to AttackQueue")
	requestQueueAtk.append(Turn.new(card))
	if requestQueuePath.is_empty():
		print("PathQueue is empty, process Attack")
		processAttackRequest()

func processAttackRequest():
	print("Try process Attack")
	if !processingAtk and !requestQueueAtk.is_empty():
		reqAtk = requestQueueAtk.pop_front()
		print("Processing Attack for " + reqAtk.card.name)
		processingAtk = true
		attackTarget()

func attackTarget():
	print(reqAtk.card.name + " Attack " + reqAtk.target.name)
	reqAtk.card.getSkill().attackTarget(reqAtk.target)
	shootProjectile()

func shootProjectile():
	print("Shoot projectile")
	var newproj = proj.instantiate()
	newproj.global_position = reqAtk.card.getSpritePos()
	newproj.setProjectile(reqAtk.card,reqAtk.target,reqAtk.damage)
	call_deferred("add_child", newproj)

func attackedTarget():
	print("Target Attacked")
	processingAtk = false
	turnRequestProcessed()

func turnRequestProcessed():
	print("Attack processed for " + reqAtk.card.name)
	if requestQueueAtk.is_empty():
		print("r")
		gState.n()
	else:
		print("AttackQueue is not empty, process Attack")
		processAttackRequest()

func _on_game_state_new_turn(currentState):
	requestQueuePath.clear()
	reqPath = null
	processingPath = false
	requestQueueAtk.clear()
	reqAtk = null
	processingAtk = false
	opponent.clear()
	team.clear()
	if currentState == gState.states.PlayerTurn || currentState == gState.states.GoToRoom:
		for p in gState.players.get_children():
			team.append(p)
		for e in gState.enemies.get_children():
			opponent[e] = e.getStatus().getCurrentValue(Stat.T.hp)
	elif currentState == gState.states.EntityTurn:
		for e in gState.enemies.get_children():
			team.append(e)
		for p in gState.players.get_children():
			opponent[p] = p.getStatus().getCurrentValue(Stat.T.hp)

class Turn:
	var card : Card
	var target : Card
	var damage : int
	func _init(card_ : Card):
		card = card_
