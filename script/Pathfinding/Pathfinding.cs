using Godot;
using System.Collections;
using System.Collections.Generic;

public partial class Pathfinding : Node{
    Dictionary<Vector2I,Tile_PF> grid;
    void FindPath(Vector3 startPos, Vector3 targetPos){

		Tile_PF startNode = grid.NodeFromWorldPoint(startPos);
		Tile_PF targetNode = grid.NodeFromWorldPoint(targetPos);

		Heap<Tile_PF> openSet = new Heap<Tile_PF>(grid.MaxSize);
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

	void RetracePath(Tile_PF startNode, Tile_PF endNode) {
		List<Tile_PF> path = new List<Tile_PF>();
		Tile_PF currentNode = endNode;

		while (currentNode != startNode) {
			path.Add(currentNode);
			currentNode = currentNode.parent;
		}
		path.Reverse();

		grid.path = path;

	}

	int GetDistance(Tile_PF nodeA, Tile_PF nodeB) {
		int dstX = Mathf.Abs(nodeA.gridX - nodeB.gridX);
		int dstY = Mathf.Abs(nodeA.gridY - nodeB.gridY);

		if (dstX > dstY)
			return 14*dstY + 10* (dstX-dstY);
		return 14*dstX + 10 * (dstY-dstX);
	}
}