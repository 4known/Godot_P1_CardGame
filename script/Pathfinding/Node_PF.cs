using Godot;

public partial class Node_PF : IHeapItem<Node_PF>
{
    public bool walkable;
	public bool occupied;
	public int gridX;
	public int gridY;

	public int gCost;
	public int hCost;
	public int fCost { get { return gCost + hCost; } }
	public Node_PF parent;
	public Node_PF(bool walkable, int gridX, int gridY)
	{
		this.walkable = walkable;
		occupied = false;
		this.gridX = gridX;
		this.gridY = gridY;
	}

	int heapIndex;
	public int HeapIndex
	{
		get { return heapIndex; }
		set { heapIndex = value; }
	}
	public int CompareTo(Node_PF nodeToCompare)
	{
		int compare = fCost.CompareTo(nodeToCompare.fCost);
		if (compare == 0)
		{
			compare = hCost.CompareTo(nodeToCompare.hCost);
		}
		return -compare;
	}
}
