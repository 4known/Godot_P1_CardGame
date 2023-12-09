using Godot;
using System.Collections.Generic;

public partial class Heap : GodotObject{
    List<Node_PF> items = new List<Node_PF>();
	int currentItemCount;
	
	public void Add(Node_PF item) {
		item.HeapIndex = currentItemCount;
		items[currentItemCount] = item;
		SortUp(item);
		currentItemCount++;
	}

	public Node_PF RemoveFirst() {
		Node_PF firstItem = items[0];
		currentItemCount--;
		items[0] = items[currentItemCount];
		items[0].HeapIndex = 0;
		SortDown(items[0]);
		return firstItem;
	}

	public void UpdateItem(Node_PF item) {
		SortUp(item);
	}

	public int Count {
		get {
			return currentItemCount;
		}
	}

	public bool Contains(Node_PF item) {
		return Equals(items[item.HeapIndex], item);
	}

	void SortDown(Node_PF item) {
		while (true) {
			int childIndexLeft = item.HeapIndex * 2 + 1;
			int childIndexRight = item.HeapIndex * 2 + 2;
			int swapIndex = 0;

			if (childIndexLeft < currentItemCount) {
				swapIndex = childIndexLeft;

				if (childIndexRight < currentItemCount) {
					if (items[childIndexLeft].CompareTo(items[childIndexRight]) < 0) {
						swapIndex = childIndexRight;
					}
				}

				if (item.CompareTo(items[swapIndex]) < 0) {
					Swap (item,items[swapIndex]);
				}
				else {
					return;
				}
			}
			else {
				return;
			}
		}
	}
	
	void SortUp(Node_PF item) {
		int parentIndex = (item.HeapIndex-1)/2;
		while (true) {
			Node_PF parentItem = items[parentIndex];
			if (item.CompareTo(parentItem) > 0) {
				Swap (item,parentItem);
			}
			else {
				break;
			}
			parentIndex = (item.HeapIndex-1)/2;
		}
	}
	
	void Swap(Node_PF itemA, Node_PF itemB) {
		items[itemA.HeapIndex] = itemB;
		items[itemB.HeapIndex] = itemA;
		int itemAIndex = itemA.HeapIndex;
		itemA.HeapIndex = itemB.HeapIndex;
		itemB.HeapIndex = itemAIndex;
	}
}