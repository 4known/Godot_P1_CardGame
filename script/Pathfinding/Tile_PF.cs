using Godot;
using System;

public partial class Tile_PF : Node
{
    public bool walkable;
	public Vector2I tileposition;
	public int gridX;
	public int gridY;

	public int gCost;
	public int hCost;
	public int fCost { get { return gCost + hCost; } }
	public Tile_PF parent;
	public Node grid;

	public Tile_PF(bool walkable, Vector2I tilePosition, int gridX, int gridY, Node grid)
	{
		this.walkable = walkable;
		this.tileposition = tilePosition;
		this.gridX = gridX;
		this.gridY = gridY;
		this.grid = grid;
	}

	int heapIndex;
	public int HeapIndex
	{
		get
		{
			return heapIndex;
		}
		set
		{
			heapIndex = value;
		}
	}
	public int CompareTo(Tile_PF nodeToCompare)
	{
		int compare = fCost.CompareTo(nodeToCompare.fCost);
		if (compare == 0)
		{
			compare = hCost.CompareTo(nodeToCompare.hCost);
		}
		return -compare;
	}
}
