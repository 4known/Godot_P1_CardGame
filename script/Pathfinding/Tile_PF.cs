using Godot;
using System;

public partial class Tile_PF : Node
{
    public bool walkable;
	public Vector2I worldPosition;
	public int gridX;
	public int gridY;

	public int gCost;
	public int hCost;
	public int fCost { get { return gCost + hCost; } }
	public Tile_PF parent;
	public Node ngrid;

	public Tile_PF(bool walkable, Vector2I worldPosition, int gridX, int gridY, Node ngrid)
	{
		this.walkable = walkable;
		this.worldPosition = worldPosition;
		this.gridX = gridX;
		this.gridY = gridY;
		this.ngrid = ngrid;
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
