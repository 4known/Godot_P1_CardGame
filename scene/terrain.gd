extends TileMap
class_name Terrain

@onready var pf = $Pathfinding
@onready var gen = $TerrainGeneration
var destinations : PackedVector2Array = []

var size : int = 20
var noise

func _ready():
	generateTerrain()

func generateTerrain():
	clear_layer(0)
	pf.ClearGrid()
	for p in gen.GenerateWorld(2, 15):
		set_cell(0,p,1,Vector2i(1,0))
	for t in get_used_cells(0):
		pf.AddToGrid(t);

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
