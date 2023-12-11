extends TileMap
class_name Terrain

@onready var pf = $Pathfinding
@onready var gen = $TerrainGeneration
var destinations : PackedVector2Array = []

var size : int = 20
var noise

func _ready():
	clear_layer(0)
	pf.ClearGrid()
	generateTerrain()

func generateTerrain():
	var grid = gen.GenerateWorld(1, 15)
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
