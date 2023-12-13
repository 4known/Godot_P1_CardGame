using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

[GlobalClass]
public partial class Pathfinding : Node
{
    Dictionary<Vector2I,Node_PF> grid = new Dictionary<Vector2I, Node_PF>();
    Godot.Collections.Array<Vector2I> GetPath(Vector2I myTilepos, Vector2I targetTilepos, int range, bool border){
        var path = new Godot.Collections.Array<Vector2I>{myTilepos};

        int tileDistance = GetTileDistance(myTilepos,targetTilepos);
        if ((tileDistance < range) ? !border : (tileDistance == range)){
			return path;
		}
		if(!grid.ContainsKey(myTilepos) || !grid.ContainsKey(targetTilepos)){
			return path;
		}
			
        Dictionary<int, List<Vector2I>> possibleTiles = GetPossibleTiles(myTilepos,targetTilepos,range,border);
        int[] sortedKeys = possibleTiles.Keys.ToArray();
        Array.Sort(sortedKeys);

        bool pathfound = false;
        foreach (int key in sortedKeys){
            foreach (Vector2I position in possibleTiles[key]){
                var p = FindPath(myTilepos,position);
                if (p.Count > 0){
					path = p;
                    pathfound = true;
                    break;
                }
            }
            if(pathfound)
                break;
        }
        return path;
    }
    Godot.Collections.Array<Vector2I> FindPath(Vector2I startPos, Vector2I targetPos){
        var waypoints = new Godot.Collections.Array<Vector2I>();
		bool pathSuccess = false;
		
		Node_PF startNode = grid[startPos];
		Node_PF targetNode = grid[targetPos];

		if (startNode.walkable && targetNode.walkable) {
            Heap<Node_PF> openSet = new Heap<Node_PF>();
		    HashSet<Node_PF> closedSet = new HashSet<Node_PF>();
		    openSet.Add(startNode);
			
			while (openSet.Count > 0) {
				Node_PF currentNode = openSet.RemoveFirst();
				closedSet.Add(currentNode);
				
				if (currentNode == targetNode) {
					pathSuccess = true;
					break;
				}
				
				foreach (Node_PF neighbour in GetNeighbours(currentNode)) {
					if (closedSet.Contains(neighbour)) {
						continue;
					}
					
					int newMovementCostToNeighbour = currentNode.gCost + GetNodeDistance(currentNode, neighbour);
					if (newMovementCostToNeighbour < neighbour.gCost || !openSet.Contains(neighbour)) {
						neighbour.gCost = newMovementCostToNeighbour;
						neighbour.hCost = GetNodeDistance(neighbour, targetNode);
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

    Godot.Collections.Array<Vector2I> RetracePath(Node_PF startNode, Node_PF endNode) {
		List<Node_PF> path = new List<Node_PF>();
		Node_PF currentNode = endNode;
		
		while (currentNode != startNode) {
			path.Add(currentNode);
			currentNode = currentNode.parent;
		}
		var waypoints = new Godot.Collections.Array<Vector2I>();
		for (int i = path.Count-1; i >= 0; i--) {
			waypoints.Add(new Vector2I(path[i].gridX,path[i].gridY));
		}
		return waypoints;
	}

	public void AddToGrid(Vector2I position){
		grid.Add(position, new Node_PF(true, position.X, position.Y));
	}
	public void RemoveFromGrid(Vector2I position){
		grid.Remove(position);
	}
	public bool GridContains(Vector2I position){
		return grid.ContainsKey(position);
	}
	public void ClearGrid(){
		grid.Clear();
	}
	public void SetNodeOccupied(Vector2I position, bool occupied){
		if (grid.ContainsKey(position)){
			grid[position].occupied = occupied;
		}
	}
	public bool IsOccupied(Vector2I position){
		return grid[position].occupied;
	}

	int GetNodeDistance(Node_PF nodeA, Node_PF nodeB) {
		int dstX = Mathf.Abs(nodeA.gridX - nodeB.gridX);
		int dstY = Mathf.Abs(nodeA.gridY - nodeB.gridY);

		if (dstX > dstY)
			return 14*dstY + 10* (dstX-dstY);
		return 14*dstX + 10 * (dstY-dstX);
	}
    int GetTileDistance(Vector2I myTilepos, Vector2I targetTilepos){
        int x = Mathf.Abs(targetTilepos.X - myTilepos.X);
        int y = Mathf.Abs(targetTilepos.Y - myTilepos.Y);
        return Mathf.Max(x,y);
    }
    public List<Node_PF> GetNeighbours(Node_PF node) {
		List<Node_PF> neighbours = new List<Node_PF>();

		for (int x = -1; x <= 1; x++) {
			for (int y = -1; y <= 1; y++) {
				if (x == 0 && y == 0)
					continue;

				int checkX = node.gridX + x;
				int checkY = node.gridY + y;
                Vector2I key = new Vector2I(checkX,checkY);
                if (grid.ContainsKey(key)){
					if (!grid[key].walkable){
						continue;
					}
                    neighbours.Add(grid[key]);
                }
			}
		}
		return neighbours;
	}

    Dictionary<int, List<Vector2I>> GetPossibleTiles(Vector2I myTilepos, Vector2I targetTilepos, int range, bool border){
        Dictionary<int, List<Vector2I>> dict = new Dictionary<int, List<Vector2I>>();
        for (int i = -range; i <= range; i++){
            for (int j = -range; j <= range; j++){
                if (border && i != -range && i != range && j != -range && j != range)
                    continue;
                if(i == 0 && j == 0)
                    continue;
                Vector2I position = new Vector2I(targetTilepos.X + i, targetTilepos.Y + j);
                if(grid.ContainsKey(position)){
					if (!grid[position].walkable || grid[position].occupied){
						continue;
					}
                    int distance = GetTileDistance(myTilepos,position);
                    if (!dict.ContainsKey(distance))
					    dict[distance] = new List<Vector2I>();
					dict[distance].Add(position);
                }
            }
        }
        return dict;
    }
}