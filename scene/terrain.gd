extends TileMap
class_name Terrain

var astargrid : AStarGrid2D
var destinations : Array[Vector2i] = []

var size : int = 20
var noise

func _ready():
	generateTerrain()
	astargrid = AStarGrid2D.new()
	astargrid.region = get_used_rect()
	astargrid.cell_size = Vector2i(32,16)
	astargrid.update()

func generateTerrain():
	clear_layer(0)
	noise = FastNoiseLite.new()
	noise.seed = randi()
	for x in range(-size,size):
		for y in range(-size,size):
			var noiseValue = noise.get_noise_2d(x,y)
			set_cell(0, Vector2i(x,y),1,Vector2i(ceil(noiseValue),0))

func getPath(myposition : Vector2i, targetpos : Vector2i, range_ : int, border : bool) -> Array[Vector2i]:
	var myTilepos = local_to_map(myposition)
	var targetTilepos = local_to_map(targetpos)
	var path : Array[Vector2i] = [myTilepos]
	path = findPath(myTilepos,targetTilepos, range_, border)
	if path.is_empty(): 
		path = [myTilepos]
	addDestination(path.back(),true)
	return path

func findPath(myTilepos : Vector2i, targetTilepos : Vector2i, range_ : int, border : bool):
	var path : Array[Vector2i] = [myTilepos]
	var tileDistance = getTileDistance(myTilepos,targetTilepos)
	if  tileDistance < range_ if !border else tileDistance == range_:
		return path
	var dict = getPossibleTiles(myTilepos,targetTilepos,range_,border)
	var keys = dict.keys()
	keys.sort()
	for key in keys:
		for pos in dict[key]:
			path = astargrid.get_id_path(myTilepos,pos)
			if !path.is_empty():
				break
		break
	path.pop_front()
	return path

func getDistance(myposition : Vector2i, targetpos : Vector2i) ->int:
	var myTilepos = local_to_map(myposition)
	var targetTilepos = local_to_map(targetpos)
	var x = abs(targetTilepos.x - myTilepos.x)
	var y = abs(targetTilepos.y - myTilepos.y)
	return max(x,y)

func getTileDistance(myTilepos : Vector2i, targetTilepos : Vector2i) ->int:
	var x = abs(targetTilepos.x - myTilepos.x)
	var y = abs(targetTilepos.y - myTilepos.y)
	return max(x,y)

func getPossibleTiles(myTilepos: Vector2i, targetTilepos : Vector2i, range_ : int, border : bool) -> Dictionary:
	var dict = {}
	for i in range(-range_, range_+1):
		for j in range(-range_, range_+1):
			if border and i != -range_ and i != range_ and j != -range_ and j != range_:
				continue
			if i == 0 and j == 0:
				continue  
			var pos = Vector2i(targetTilepos.x + i, targetTilepos.y + j)
			if astargrid.is_in_boundsv(pos) and !astargrid.is_point_solid(pos) :
				var x = abs(pos.x - myTilepos.x)
				var y = abs(pos.y - myTilepos.y)
				var key = max(x,y)
				if !dict.has(key):
					dict[key] = [pos]
				else:
					dict[key].append(pos)
	return dict

func addDestination(pos : Vector2i, tiled : bool):
	var p = pos
	if !tiled:
		p = local_to_map(pos)
	destinations.append(p)
	astargrid.set_point_solid(p,true)

func clearDestination():
	for d in destinations:
		astargrid.set_point_solid(d,false)
	destinations.clear()

func nearestTilepos(pos : Vector2i) -> Vector2i:
	var x = round(float(pos.x) / 8) * 8
	var y = round(float(pos.y) / 8) * 8
	var tilepos : Vector2i = Vector2i(x,y)
	return tilepos
