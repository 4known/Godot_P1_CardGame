extends TileMap
class_name Terrain

@onready var pf = $Pathfinding
@onready var gen = $TerrainGeneration

var world : Array[Room] = []
var roomMax : int = 5
var currentCenter : Vector2i = Vector2i.ZERO
var radius = 15

func _ready():
	clear_layer(0)
	pf.ClearGrid()
	generateTerrain()

func generateTerrain():
	#GetPosition
	var newPos = getNewPosition()
	var collision = true
	while collision:
		collision = false
		for room in world:
			if pf.GetTileDistance(room.center, newPos) < radius*2:
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
		
	#Generate Passage
	var passage : Array[Vector2i] = []
	if world.size() > 1:
		for p in gen.CreatePassage(world.back().grid + world[world.size() - 2].grid, world.back().center, world[world.size()-2].center):
			passage.push_back(p)
	#Add Passage
	world[world.size()-2].passageToNext = passage
	
	#Add to world
	for p in passage:
		if get_cell_source_id(0,p) != -1 || pf.GridContains(p):
			continue
		set_cell(0,p,1,Vector2i(0,0))
	for p in grid:
		if get_cell_source_id(0,p) != -1 || pf.GridContains(p):
			continue
		if p == currentCenter:
			set_cell(0,p,1,Vector2i(0,0))
		else:
			set_cell(0,p,1,Vector2i(1,0))

func getNewPosition() -> Vector2:
	var current : Vector2i
	var previous : Vector2i
	if world.size() > 1:
		current = world.back().center
		previous = world[world.size()-2].center
	else:
		current = currentCenter
		previous = Vector2i.ZERO

	var previousDir : Vector2i = Vector2i(previous.x - current.x,previous.y - current.y)
	var directions = getDirections(previousDir)
	var dir = directions.pick_random()
	var length = Vector2(randf_range(1.1,1.25),randf_range(1.1,1.25))
	return Vector2(current.x + dir.x * length.x * radius * 2, current.y + dir.y*length.y * radius * 2)

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
	var enemies : Array[Card]
	var radius : int
	func _init(center_ : Vector2i, grid_ : Array[Vector2i], radius_ : int):
		center = center_
		grid = grid_
		radius = radius_
