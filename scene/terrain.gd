extends TileMap
class_name Terrain

var astar : AStar2D
var destinations : PackedVector2Array = []

var size : int = 20
var noise

func _ready():
#	generateTerrain()
	astar = AStar2D.new()
	for t in get_used_cells(0):
		astar.add_point(getID(t),t)

func generateTerrain():
	clear_layer(0)
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency *= 20
	for x in range(-size,size):
		for y in range(-size,size):
			var noiseValue = noise.get_noise_2d(x,y)
			set_cell(0, Vector2i(x,y),1,Vector2i(ceil(noiseValue),0))

func getID(tilepos : Vector2i) -> int:
	tilepos -= get_used_rect().position
	return tilepos.y*get_used_rect().size.x + tilepos.x

func getPath(myposition : Vector2i, targetpos : Vector2i, range_ : int, border : bool) -> PackedVector2Array:
	var myTilepos = local_to_map(myposition)
	var targetTilepos = local_to_map(targetpos)
	var path : PackedVector2Array
	path = findPath(myTilepos,targetTilepos, range_, border)
	if path.is_empty(): 
		path.append(myTilepos)
	addDestination(path[path.size()-1],true)
	return path

func findPath(myTilepos : Vector2i, targetTilepos : Vector2i, range_ : int, border : bool):
	var path : PackedVector2Array
	path.append(myTilepos)
	var tileDistance = getTileDistance(myTilepos,targetTilepos)
	if  tileDistance < range_ if !border else tileDistance == range_:
		return path
	var dict = getPossibleTiles(myTilepos,targetTilepos,range_,border)
	var keys = dict.keys()
	keys.sort()
	for key in keys:
		for pos in dict[key]:
			path = astar.get_point_path(getID(myTilepos),getID(pos))
			if !path.is_empty():
				break
		break
	path.remove_at(0)
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
			if get_cell_source_id(0,pos) != -1 and !astar.is_point_disabled(getID(pos)) :
				var x = abs(pos.x - myTilepos.x)
				var y = abs(pos.y - myTilepos.y)
				var key = max(x,y)
				if !dict.has(key):
					dict[key] = [pos]
				else:
					dict[key].append(pos)
	return dict

func addDestination(pos : Vector2i, tiled : bool):
	if !tiled:
		pos = local_to_map(pos)
		destinations.append(pos)
		if get_cell_source_id(0,pos) != -1:
			astar.set_point_disabled(getID(pos),true)
	else:
		destinations.append(pos)
		if get_cell_source_id(0,pos) != -1:
			astar.set_point_disabled(getID(pos),true)

func clearDestination():
	for d in destinations:
		astar.set_point_disabled(getID(d),false)
	destinations.clear()
