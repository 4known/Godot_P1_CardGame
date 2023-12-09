using System;
using System.Collections.Generic;

public class Heap<T> where T : IHeapItem<T>{
   	List<T> items = new List<T>();
	
	public void Add(T item) {
		item.HeapIndex = Count;
		items.Add(item);;
		SortUp(item);
	}

	public T RemoveFirst() {
		T firstItem = items[0];
		int lastIndex = items.Count - 1;
		items[0] = items[lastIndex];
		items[0].HeapIndex = 0;
		items.RemoveAt(lastIndex);
		if(items.Count > 0){
			SortDown(items[0]);
		}
		return firstItem;
	}

	public void UpdateItem(T item) {
		SortDown(item);
		SortUp(item);
	}

	public int Count {
		get {
			return items.Count;
		}
	}

	public bool Contains(T item) {
		if (item.HeapIndex < items.Count)
		{
			return Equals(items[item.HeapIndex], item);
		}

		return false;
	}

	void SortDown(T item) {
		while (true) {
			int childIndexLeft = item.HeapIndex * 2 + 1;
			int childIndexRight = item.HeapIndex * 2 + 2;
			int swapIndex = 0;

			if (childIndexLeft < items.Count) {
				swapIndex = childIndexLeft;

				if (childIndexRight < items.Count) {
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
	
	void SortUp(T item) {
		int parentIndex = (item.HeapIndex-1)/2;
		
		while (parentIndex >= 0) {
			T parentItem = items[parentIndex];
			if (item.CompareTo(parentItem) > 0) {
				Swap (item,parentItem);
			}
			else {
				break;
			}

			parentIndex = (item.HeapIndex-1)/2;
		}
	}
	
	void Swap(T itemA, T itemB) {
		items[itemA.HeapIndex] = itemB;
		items[itemB.HeapIndex] = itemA;
		int itemAIndex = itemA.HeapIndex;
		itemA.HeapIndex = itemB.HeapIndex;
		itemB.HeapIndex = itemAIndex;
	}
}

public interface IHeapItem<T> : IComparable<T> {
	int HeapIndex {
		get;
		set;
	}
}