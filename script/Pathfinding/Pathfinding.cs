using Godot;
using System;
using System.Collections.Generic;

public partial class Pathfinding : Node{
    Dictionary<Vector2I,Tile_PF> grid;

    Vector2I[] FindPath(Vector2I startPos, Vector2I targetPos){
        Vector2I[] waypoints = new Vector2I[0];
		bool pathSuccess = false;
		
		Tile_PF startNode = grid[startPos];
		Tile_PF targetNode = grid[targetPos];

		if (startNode.walkable && targetNode.walkable) {
            Heap openSet = new Heap();
		    HashSet<Tile_PF> closedSet = new HashSet<Tile_PF>();
		    openSet.Add(startNode);
			
			while (openSet.Count > 0) {
				Tile_PF currentNode = openSet.RemoveFirst();
				closedSet.Add(currentNode);
				
				if (currentNode == targetNode) {
					pathSuccess = true;
					break;
				}
				
				foreach (Tile_PF neighbour in GetNeighbours(currentNode)) {
					if (!neighbour.walkable || closedSet.Contains(neighbour)) {
						continue;
					}
					
					int newMovementCostToNeighbour = currentNode.gCost + GetDistance(currentNode, neighbour);
					if (newMovementCostToNeighbour < neighbour.gCost || !openSet.Contains(neighbour)) {
						neighbour.gCost = newMovementCostToNeighbour;
						neighbour.hCost = GetDistance(neighbour, targetNode);
						neighbour.parent = currentNode;
						
						if (!openSet.Contains(neighbour))
							openSet.Add(neighbour);
					}
				}
			}
		}
		if (pathSuccess) {
			waypoints = RetracePath(startNode,targetNode);
		}
		return waypoints;
	}

    Vector2I[] RetracePath(Tile_PF startNode, Tile_PF endNode) {
		List<Tile_PF> path = new List<Tile_PF>();
		Tile_PF currentNode = endNode;
		
		while (currentNode != startNode) {
			path.Add(currentNode);
			currentNode = currentNode.parent;
		}
		Vector2I[] waypoints = SimplifyPath(path);
		Array.Reverse(waypoints);
		return waypoints;
	}
    Vector2I[] SimplifyPath(List<Tile_PF> path) {
		List<Vector2I> waypoints = new List<Vector2I>();
		Vector2I directionOld = Vector2I.Zero;
		
		for (int i = 1; i < path.Count; i ++) {
			Vector2I directionNew = new Vector2I(path[i-1].gridX - path[i].gridX,path[i-1].gridY - path[i].gridY);
			if (directionNew != directionOld) {
				waypoints.Add(path[i].tileposition);
			}
			directionOld = directionNew;
		}
		return waypoints.ToArray();
	}

	int GetDistance(Tile_PF nodeA, Tile_PF nodeB) {
		int dstX = Mathf.Abs(nodeA.gridX - nodeB.gridX);
		int dstY = Mathf.Abs(nodeA.gridY - nodeB.gridY);

		if (dstX > dstY)
			return 14*dstY + 10* (dstX-dstY);
		return 14*dstX + 10 * (dstY-dstX);
	}

    public List<Tile_PF> GetNeighbours(Tile_PF node) {
		List<Tile_PF> neighbours = new List<Tile_PF>();

		for (int x = -1; x <= 1; x++) {
			for (int y = -1; y <= 1; y++) {
				if (x == 0 && y == 0)
					continue;

				int checkX = node.gridX + x;
				int checkY = node.gridY + y;
                Vector2I key = new Vector2I(checkX,checkY);
                if (grid.ContainsKey(key)){
                    neighbours.Add(grid[key]);
                }
			}
		}

		return neighbours;
	}
}