using Godot;
using System.Collections;
using System.Collections.Generic;

public partial class Pathfinding : Node{
    Dictionary<Vector2I,Tile_PF> grid;
    void FindPath(Vector2I startPos, Vector2I targetPos){

		Tile_PF startNode = grid[startPos];
		Tile_PF targetNode = grid[targetPos];

		Heap openSet = new Heap(grid.MaxSize);
		HashSet<Tile_PF> closedSet = new HashSet<Tile_PF>();
		openSet.Add(startNode);

		while (openSet.Count > 0) {
			Tile_PF currentNode = openSet.RemoveFirst();
			closedSet.Add(currentNode);

			if (currentNode == targetNode) {
				RetracePath(startNode,targetNode);
				return;
			}

			foreach (Tile_PF neighbour in grid.GetNeighbours(currentNode)) {
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
					else {
						//openSet.UpdateItem(neighbour);
					}
				}
			}
		}
	}

	List<Tile_PF> RetracePath(Tile_PF startNode, Tile_PF endNode) {
		List<Tile_PF> path = new List<Tile_PF>();
		Tile_PF currentNode = endNode;

		while (currentNode != startNode) {
			path.Add(currentNode);
			currentNode = currentNode.parent;
		}
		path.Reverse();

		return path;
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

				if (checkX >= 0 && checkX < gridSizeX && checkY >= 0 && checkY < gridSizeY) {
					neighbours.Add(grid[checkX,checkY]);
				}
			}
		}

		return neighbours;
	}
}