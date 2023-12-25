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
var opponent : Dictionary = {}
var team : Array[Card] = []
#Projectile
const proj = preload("res://Scene/projectile.tscn")

func _ready():
	Signals.connect("requestTurn",requestTurn)
	Signals.connect("arrivedNowAttack", requestAttack)
	Signals.connect("projectileHitTarget", requestProcessed)

func requestTurn(card : Card):
	if card.getStatus().getCurrentValue(Stat.T.hp) > 0:
		var newRequest = Turn.new(card)
		requestQueuePath.append(newRequest)
		nextRequestPath()

func nextRequestPath():
	if !processingPath and !requestQueuePath.is_empty():
		reqPath = requestQueuePath.pop_front()
		if is_instance_valid(reqPath.card):
			processingPath = true
			firstFindTarget()
		else:
			requestProcessed()

func firstFindTarget():
	if opponent.is_empty():
		requestProcessed()
		processingPath = false
		return
	var target = null
	var cardp = reqPath.card.global_position
	var currentdis = null
	for o in opponent:
		if is_instance_valid(o):
			if target == null:
				target = o
				currentdis = ter.getDistance(cardp,target.global_position)
			var distance = ter.getDistance(cardp,o.global_position)
			if distance < currentdis:
				target = o
				currentdis = distance
	if target == null:
		requestProcessed()
		return
	reqPath.target = target
	var damage = 30 * -1
	reqPath.damage = damage
	opponent[target] -= reqPath.target.getStatus().calculateDamage(damage*-1)
	if opponent[target] <= 0:
		opponent.erase(reqPath.target)
	secondFindPath()

func secondFindPath():
	var range_ = 4
	var cardp = reqPath.card.global_position
	var targetp = reqPath.target.global_position
	var path = ter.getPath(cardp,targetp,range_,true)
	reqPath.card.setPath(path)
	if reqPath.card.onlyPath:
		processingPath = false
		nextRequestPath()

func requestAttack():
	requestQueueAtk.append(reqPath)
	processingPath = false
	nextRequestPath()
	nextRequestAttack()

func nextRequestAttack():
	if !processingAtk and !requestQueueAtk.is_empty():
		reqAtk = requestQueueAtk.pop_front()
		if is_instance_valid(reqAtk.card) and is_instance_valid(reqAtk.target):
			processingAtk = true
			thirdAttack()
		else:
			requestProcessed()

func thirdAttack():
	reqAtk.card.getSkill().attackTarget(reqAtk.target)
	shootProjectile()

func shootProjectile():
	var newproj = proj.instantiate()
	newproj.global_position = reqAtk.card.getSpritePos()
	newproj.setProjectile(reqAtk.card,reqAtk.target,reqAtk.damage)
	call_deferred("add_child", newproj)

func requestProcessed():
	processingAtk = false
	if requestQueueAtk.is_empty() and requestQueuePath.is_empty():
		print("r")
		gState.n()
	else:
		nextRequestAttack()
		if !processingPath:
			nextRequestPath()

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
