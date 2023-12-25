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
	if card.getStatus().getCurrentValue(Stat.T.hp) > 0:
		requestQueuePath.append(Turn.new(card))
		nextRequestPath()

func nextRequestPath():
	if !processingPath and !requestQueuePath.is_empty():
		reqPath = requestQueuePath.pop_front()
		processingPath = true
		firstFindPath()

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
	reqPath.target = target
	var damage = 30 * -1
	reqPath.damage = damage
	opponent[target] -= reqPath.target.getStatus().calculateDamage(damage*-1)
	if opponent[target] <= 0:
		opponent.erase(reqPath.target)

func firstFindPath():
	findTarget()
	var range_ = 4
	var cardpos = reqPath.card.global_position
	var targetp = reqPath.target.global_position
	var path = ter.getPath(cardpos,targetp,range_,true)
	reqPath.card.setPath(path)
	if reqPath.card.onlyPath:
		processingPath = false
		nextRequestPath()

func requestAttack():
	pass

func nextRequestAttack():
	pass

func thirdAttack():
	reqAtk.card.getSkill().attackTarget(reqAtk.target)
	shootProjectile()

func shootProjectile():
	var newproj = proj.instantiate()
	newproj.global_position = reqAtk.card.getSpritePos()
	newproj.setProjectile(reqAtk.card,reqAtk.target,reqAtk.damage)
	call_deferred("add_child", newproj)

func attackedTarget():
	processingAtk = false
	requestProcessed()

func requestProcessed():
	if requestQueueAtk.is_empty() and requestQueuePath.is_empty():
		print("r")
		gState.n()
	else:
		nextRequestPath()
		nextRequestAttack()

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
