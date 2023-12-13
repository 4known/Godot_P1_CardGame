extends TileMap
class_name Terrain

@onready var pf = $Pathfinding
@onready var gen = $TerrainGeneration

var world : Array[Room] = []
var currentCenter : Vector2i = Vector2i.ZERO
var radius = 15

func _ready():
	clear_layer(0)
	pf.ClearGrid()
	generateTerrain()

func generateTerrain():
	var excludemin = -1.5
	var excludemax = 1.5
	var offset = Vector2.ZERO
	while offset.x < excludemax && offset.x > excludemin || offset.y < excludemax && offset.y > excludemin:
		offset = Vector2(randf_range(-3,3),randf_range(-3,3))
	currentCenter.x += offset.x*radius;
	currentCenter.y += offset.y*radius;
	
	var preCenter : Vector2i = currentCenter
	if !world.is_empty():
		preCenter = world.back().center
	
	var grid : Array[Vector2i] = []
	for p in gen.GenerateWorld(radius,currentCenter,preCenter):
		grid.push_back(p)
		
	world.append(Room.new(currentCenter,grid))
	
	for p in grid:
		if get_cell_source_id(0,p) != -1:
			continue
		set_cell(0,p,1,Vector2i(1,0))
	for t in grid:
		if pf.GridContains(t):
			continue
		pf.AddToGrid(t)

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
