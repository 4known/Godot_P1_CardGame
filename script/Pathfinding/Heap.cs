using Godot;
using System.Collections.Generic;

public partial class Heap : GodotObject{
    Tile_PF[] items;
	int currentItemCount;
	
	public Heap(int maxHeapSize) {
		items = new Tile_PF[maxHeapSize];
	}
	
	public void Add(Tile_PF item) {
		item.HeapIndex = currentItemCount;
		items[currentItemCount] = item;
		SortUp(item);
		currentItemCount++;
	}

	public Tile_PF RemoveFirst() {
		Tile_PF firstItem = items[0];
		currentItemCount--;
		items[0] = items[currentItemCount];
		items[0].HeapIndex = 0;
		SortDown(items[0]);
		return firstItem;
	}

	public void UpdateItem(Tile_PF item) {
		SortUp(item);
	}

	public int Count {
		get {
			return currentItemCount;
		}
	}

	public bool Contains(Tile_PF item) {
		return Equals(items[item.HeapIndex], item);
	}

	void SortDown(Tile_PF item) {
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
	
	void SortUp(Tile_PF item) {
		int parentIndex = (item.HeapIndex-1)/2;
		
		while (true) {
			Tile_PF parentItem = items[parentIndex];
			if (item.CompareTo(parentItem) > 0) {
				Swap (item,parentItem);
			}
			else {
				break;
			}

			parentIndex = (item.HeapIndex-1)/2;
		}
	}
	
	void Swap(Tile_PF itemA, Tile_PF itemB) {
		items[itemA.HeapIndex] = itemB;
		items[itemB.HeapIndex] = itemA;
		int itemAIndex = itemA.HeapIndex;
		itemA.HeapIndex = itemB.HeapIndex;
		itemB.HeapIndex = itemAIndex;
	}
}