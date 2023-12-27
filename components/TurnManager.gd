extends Node
class_name TurnManager

@onready var ter = $"../Terrain"
@onready var gState = $"../GameState"
#Manager
var requestQueuePath : Array[Card] = []
var requestQueueAtk : Array[Card] = []
var reqPath : Card = null
var reqAtk : Card = null
var processingPath : bool = false
var processingAtk : bool = false

var opponent : Dictionary = {} #Card : supposeStat class
var team : Array[Card] = []

var reqOnlyPath : Array[Card] = []
#Projectile
const proj = preload("res://Scene/projectile.tscn")

func _ready():
	Signals.connect("requestTurn",requestTurn)
	Signals.connect("arrivedNowAttack", requestAttack)
	Signals.connect("projectileHitTarget", attackedTarget)

func requestTurn(card : Card):
	print("Add " + card.name + " to PathQueue")
	requestQueuePath.append(card)

func processPathRequest():
	#print("Try process Path")
	if !processingPath and !requestQueuePath.is_empty():
		reqPath = requestQueuePath.pop_front()
		print("Processing Path for " + reqPath.name)
		processingPath = true
		findTarget()

func findTarget():
	if opponent.is_empty():
		#print("No enemy, clear PathQueue")
		requestQueuePath.clear()
		pathRequestProcessed()
		return
	var target : Card = null
	var minDistance : int
	for enemy in opponent:
		if target == null:
			target = enemy
			minDistance = ter.getDistance(reqPath.global_position,target.global_position)
			continue
		var distance = ter.getDistance(reqPath.global_position,enemy.global_position)
		if distance < minDistance:
			target = enemy
			minDistance = distance
	#print(reqPath.name + " Target is " + target.name)
	reqPath.setTarget(target)
	if !reqPath.onlyPath:
		calculateDamage(target)
	else:
		reqOnlyPath.append(reqPath)
	findPath()

func calculateDamage(target : Card):
	#print("Damage is " + str(reqPath.damage))
	#print("Target currentHP is " + str(opponent[target].hp))
	opponent[target].hp += reqPath.target.getStatus().calculateDamage(reqPath.damage,opponent[target].def)
	for effect in reqPath.getSkill().skill.skillEftArr:
		if effect.statusEffect.type == Stat.T.def:
			opponent[target].def += target.getStatus().statusDict[Stat.T.def].calModValue(effect.statusEffect.statModArr[effect.tier])
			continue
	#print("Target supposeHP is " + str(opponent[target].hp))
	if opponent[target].hp <= 0:
		#print("Target hp depleted")
		opponent.erase(reqPath.target)

func findPath():
	##print("Find Target for " + reqPath.name)
	var range_ = 4
	var cardpos = reqPath.global_position
	var targetp = reqPath.target.global_position
	var path = ter.getPath(cardpos,targetp,range_,true)
	print("Found path for " + reqPath.name)
	reqPath.setPath(path)
	processingPath = false
	pathRequestProcessed()

func pathRequestProcessed():
	#print("Path processed for " + reqPath.name)
	if !requestQueuePath.is_empty():
		##print("PathQueue not empty, process next")
		processPathRequest()

func requestAttack(card : Card):
	if reqOnlyPath.has(card):
		#print("Remove " + card.name + " from reqOnlyPath")
		reqOnlyPath.erase(card)
		turnRequestProcessed()
		return
	print("Add " + card.name + " to AttackQueue")
	requestQueueAtk.append(card)
	if requestQueuePath.is_empty():
		##print("PathQueue is empty, process Attack")
		processAttackRequest()

func processAttackRequest():
	#print("Try process Attack")
	if !processingAtk and !requestQueueAtk.is_empty():
		reqAtk = requestQueueAtk.pop_front()
		print("Processing Attack for " + reqAtk.name)
		processingAtk = true
		attackTarget()

func attackTarget():
	print(reqAtk.name + " Attack " + reqAtk.target.name)
	shootProjectile()

func shootProjectile():
	##print("Shoot projectile")
	var newproj = proj.instantiate()
	newproj.global_position = reqAtk.getSpritePos()
	newproj.setProjectile(reqAtk,reqAtk.target,reqAtk.damage)
	call_deferred("add_child", newproj)

func attackedTarget():
	#print("Target Attacked")
	#print("Target hp: " + str(reqAtk.target.getStatus().getCurrentValue(Stat.T.hp)))
	processingAtk = false
	turnRequestProcessed()

func turnRequestProcessed():
	if requestQueueAtk.is_empty() && reqOnlyPath.is_empty():
		#print("Turn End")
		gState.n()
	elif !requestQueueAtk.is_empty():
		#print("Attack processed for " + reqAtk.name)
		#print("AttackQueue is not empty, process Attack")
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
	reqOnlyPath.clear()
	if currentState == gState.states.PlayerTurn || currentState == gState.states.GoToRoom:
		for p in gState.players.get_children():
			team.append(p)
		for e in gState.enemies.get_children():
			opponent[e] = supposeStat.new(e.getStatus().getCurrentValue(Stat.T.hp),0)
	elif currentState == gState.states.EntityTurn:
		for e in gState.enemies.get_children():
			team.append(e)
		for p in gState.players.get_children():
			opponent[p] = supposeStat.new(p.getStatus().getCurrentValue(Stat.T.hp),0)

class supposeStat:
	var hp : int
	var def : int
	func _init(hp_ : int, def_ : int):
		hp = hp_
		def = def_
