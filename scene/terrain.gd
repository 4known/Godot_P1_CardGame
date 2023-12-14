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
	var offset = getOffset(Vector2i.DOWN)
	currentCenter.x += offset.x*radius;
	currentCenter.y += offset.y*radius;
	
	var preCenter : Vector2i = currentCenter
	if !world.is_empty():
		preCenter = world.back().center
	
	var grid : Array[Vector2i] = []
	for p in gen.GenerateWorld(radius,currentCenter,preCenter):
		grid.push_back(p)
	
	world.push_back(Room.new(currentCenter,grid))
	if world.size()> roomMax:
		for p in world.front().grid:
			erase_cell(0,p)
			pf.RemoveFromGrid(p)
		world.pop_front()
	
	for p in grid:
		if get_cell_source_id(0,p) != -1 || pf.GridContains(p):
			continue
		set_cell(0,p,1,Vector2i(1,0))
		pf.AddToGrid(p)

func getOffset(direction : Vector2i) -> Vector2:
	var directions = getDirections()
	var dir = directions.pick_random()
	var length = Vector2(randf_range(1.3,2),randf_range(1.3,2))
	return Vector2(dir.x * length.x,dir.y*length.y)

func getDirections() -> Array[Vector2i]:
	var directions : Array[Vector2i] = []
	for x in range(-1,2):
		for y in range(-1,2):
			if x == 0 and y == 0:
				continue
			directions.push_back(Vector2i(x,y))
	return directions

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
	var enemies : Array[Card]
	func _init(center_ : Vector2i, grid_ : Array[Vector2i]):
		center = center_
		grid = grid_
