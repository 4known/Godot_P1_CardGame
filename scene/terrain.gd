extends TileMap
class_name Terrain

@onready var pf = $Pathfinding
@onready var gen = $TerrainGeneration

var world : Array[Room] = []
var currentRoom : Room 
var roomMax : int = 5
var currentCenter : Vector2i = Vector2i.ZERO
var radius : int

func _ready():
	clear_layer(0)
	pf.ClearGrid()

func initGeneration():
	for i in range(ceil(roomMax/2.0)):
		generateTerrain()
	if !world.is_empty():
		currentRoom = world.front()
		for tile in currentRoom.grid:
			pf.AddToGrid(tile)
			if currentRoom.enemiesPosition.has(tile):
				pf.SetNodeOccupied(tile,true)

func generateTerrain():
	radius = randi_range(12,20)
	#GetPosition
	var newPos = getNewPosition()
	var collision = true
	while collision:
		collision = false
		for room in world:
			if pf.GetTileDistance(room.center, newPos) < room.radius + radius:
				collision = true
				break
		if collision:
			newPos = getNewPosition()
	currentCenter = newPos
	
	#Generate Room
	var grid : Array[Vector2i] = []
	for p in gen.CreateGrid(radius,currentCenter):
		grid.push_back(p)
	
	#Add room
	world.push_back(Room.new(currentCenter,grid, radius))
	if world.size()> roomMax:
		for p in world.front().grid:
			erase_cell(0,p)
		for p in world.front().passageToNext:
			erase_cell(0,p)
		world.pop_front()
	
	#Generate Enemy Position
	for i in range(5):
		var p = grid.pick_random()
		while world.back().enemiesPosition.has(p):
			p = grid.pick_random()
		world.back().enemiesPosition.push_back(p)
	
	#Generate Passage
	var passage : Array[Vector2i] = []
	if world.size() > 1:
		for p in gen.CreatePassage(world.back().grid + world[world.size() - 2].grid, world.back().center, world[world.size()-2].center):
			passage.push_back(p)
	#Add Passage
	world[world.size()-2].passageToNext = passage
	
	#Add to world
	for p in passage:
		if get_cell_source_id(0,p) != -1:
			print("collision passage")
			continue
		set_cell(0,p,1,Vector2i(0,0))
	for p in grid:
		if get_cell_source_id(0,p) != -1:
			print("collision grid")
			continue
		if p == currentCenter:
			set_cell(0,p,1,Vector2i(0,0))
		else:
			set_cell(0,p,1,Vector2i(1,0))

func getNewPosition() -> Vector2:
	var current : Vector2i
	var previous : Vector2i
	var offsetDistance = radius * 2 +1
	if world.size() > 1:
		current = world.back().center
		previous = world[world.size()-2].center
		offsetDistance = world.back().radius + radius + 1
	else:
		if world.size() == 1:
			offsetDistance = world.front().radius + radius + 1
		current = currentCenter
		previous = Vector2i.ZERO

	var previousDir : Vector2i = Vector2i(previous.x - current.x,previous.y - current.y)
	var directions = getDirections(previousDir)
	var dir = directions.pick_random()
	return Vector2(current.x + dir.x * offsetDistance, current.y + dir.y * offsetDistance)

func getDirections(dir : Vector2i) -> Array[Vector2i]:
	var dirs : Array[Vector2i] = []
	if dir.x == 0 and dir.y > 0:
		dirs = [Vector2i(-1,-1),Vector2i(0,-1),Vector2i(1,-1)]
	elif dir.x > 0 and dir.y == 0:
		dirs = [Vector2i(-1,-1),Vector2i(-1,1),Vector2i(-1,0)]
	elif dir.x == 0 and dir.y < 0:
		dirs = [Vector2i(0,1),Vector2i(1,1),Vector2i(-1,1)]
	elif dir.x < 0 and dir.y == 0:
		dirs = [Vector2i(1,0),Vector2i(1,1),Vector2i(1,-1)]
	elif dir.x < 0 and dir.y > 0:
		dirs = [Vector2i(1,0),Vector2i(0,-1),Vector2i(1,-1)]
	elif dir.x > 0 and dir.y > 0:
		dirs = [Vector2i(-1,0),Vector2i(-1,-1),Vector2i(0,-1)]
	elif dir.x < 0 and dir.y < 0:
		dirs = [Vector2i(0,1),Vector2i(1,0),Vector2i(1,1)]
	elif dir.x > 0 and dir.y < 0:
		dirs = [Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,1)]
	else:
		for i in range(-1,2):
			for j in range(-1,2):
				if i == 0 and j == 0:
					continue;
				dirs.push_back(Vector2i(i,j))
	return dirs

func getPath(myposition : Vector2i, targetpos : Vector2i, range_ : int, border : bool) -> Array[Vector2i]:
	var myTilepos = local_to_map(myposition)
	var targetTilepos = local_to_map(targetpos)
	var path : Array[Vector2i] = []
	for p in pf.GetPath(myTilepos,targetTilepos, range_, border):
		path.append(p)
	pf.SetNodeOccupied(myTilepos,false)
	pf.SetNodeOccupied(path.back(),true)
	return path

func getDistance(myposition : Vector2i, targetpos : Vector2i) -> int:
	var myTilepos = local_to_map(myposition)
	var targetTilepos = local_to_map(targetpos)
	return pf.GetTileDistance(myTilepos,targetTilepos)

class Room:
	var center : Vector2i
	var grid : Array[Vector2i]
	var passageToNext : Array[Vector2i]
	var enemiesPosition : Array[Vector2i]
	var radius : int
	func _init(center_ : Vector2i, grid_ : Array[Vector2i], radius_ : int):
		center = center_
		grid = grid_
		radius = radius_
