extends TileMap
class_name Terrain

@onready var pf = $Pathfinding
var destinations : PackedVector2Array = []

var size : int = 20
var noise

func _ready():
	for t in get_used_cells(0):
		pf.AddToGrid(t);
#	generateTerrain()

func generateTerrain():
	clear_layer(0)
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency *= 20
	for x in range(-size,size):
		for y in range(-size,size):
			var noiseValue = noise.get_noise_2d(x,y)
			set_cell(0, Vector2i(x,y),1,Vector2i(ceil(noiseValue),0))

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
