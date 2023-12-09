using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

[GlobalClass]
public partial class Pathfinding : Node
{
    Dictionary<Vector2I,Node_PF> grid = new Dictionary<Vector2I, Node_PF>();
    Godot.Collections.Array<Vector2I> GetPath(Vector2I myTilepos, Vector2I targetTilepos, int range, bool border){
        Godot.Collections.Array<Vector2I> path = new Godot.Collections.Array<Vector2I>{myTilepos};

        int tileDistance = GetTileDistance(myTilepos,targetTilepos);
        if ((tileDistance < range) ? !border : (tileDistance == range))
            return path;

        Dictionary<int, List<Vector2I>> possibleTiles = GetPossibleTiles(myTilepos,targetTilepos,range,border);
        int[] sortedKeys = possibleTiles.Keys.ToArray();
        Array.Sort(sortedKeys);

        Vector2I[] p = new Vector2I[0];
        bool pathfound = false;
        foreach (int key in sortedKeys){
            foreach (Vector2I position in possibleTiles[key]){
                p = FindPath(myTilepos,targetTilepos);
                if (p.Length > 0){
                    pathfound = true;
                    break;
                }
            }
            if(pathfound)
                break;
        }
        foreach (Vector2I position in p){
            path.Add(position);
        }
        
        if (path.Count == 0){
            path.Add(myTilepos);
        }
        return path;
    }
    Vector2I[] FindPath(Vector2I startPos, Vector2I targetPos){
        Vector2I[] waypoints = new Vector2I[0];
		bool pathSuccess = false;
		
		Node_PF startNode = grid[startPos];
		Node_PF targetNode = grid[targetPos];

		if (startNode.walkable && targetNode.walkable) {
            Heap openSet = new Heap();
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
					if (!neighbour.walkable || closedSet.Contains(neighbour)) {
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

    Vector2I[] RetracePath(Node_PF startNode, Node_PF endNode) {
		List<Node_PF> path = new List<Node_PF>();
		Node_PF currentNode = endNode;
		
		while (currentNode != startNode) {
			path.Add(currentNode);
			currentNode = currentNode.parent;
		}
		Vector2I[] waypoints = SimplifyPath(path);
		Array.Reverse(waypoints);
		return waypoints;
	}
    Vector2I[] SimplifyPath(List<Node_PF> path) {
		List<Vector2I> waypoints = new List<Vector2I>();
		Vector2I directionOld = Vector2I.Zero;
		
		for (int i = 1; i < path.Count; i ++) {
			Vector2I directionNew = new Vector2I(path[i-1].gridX - path[i].gridX,path[i-1].gridY - path[i].gridY);
			if (directionNew != directionOld) {
				waypoints.Add(new Vector2I(path[i].gridX,path[i].gridY));
			}
			directionOld = directionNew;
		}
		return waypoints.ToArray();
	}

	public void AddToGrid(Vector2I position){
		grid.Add(position, new Node_PF(true, position.X, position.Y));
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