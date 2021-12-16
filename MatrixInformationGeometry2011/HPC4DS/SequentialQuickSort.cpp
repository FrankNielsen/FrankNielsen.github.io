// filename: SequentialQuickSort.cpp
# include <vector.h>
# include <iostream.h>
# include <multiset.h>
# include <algo.h>

// pivot
template <class T>
void quickSort(vector<T>&v, unsigned int low, unsigned int high)
{  
  if (low >= high) return;
  // select median element for the pivot
  unsigned int pivotIndex = (low + high) / 2;
  // partition
  pivotIndex = pivot (v, low, high, pivotIndex);
  // sort recursively
  if (low < pivotIndex) quickSort(v, low, pivotIndex);
  if (pivotIndex < high)  quickSort(v, pivotIndex + 1, high);
}

template <class T> void quickSort(vector<T> & v)
{ 
  unsigned int numberElements = v.size ();
  if (numberElements > 1) 
    quickSort(v, 0, numberElements - 1);
}

template <class T>
unsigned int pivot (vector<T> & v, unsigned int start, 
unsigned int stop, unsigned int position)
{//swap pivot with initial position
  swap (v[start], v[position]);
  // partition values
  unsigned int low = start + 1;
  unsigned int high = stop;
  while (low < high)
    if (v[low] < v[start])
      low++;
    else if (v[--high] < v[start])
      swap (v[low], v[high]);
  // swap again pivot with initial element 
  swap (v[start], v[--low]);
  return low;
}

void main() {
  vector<int> v(100);
  for (int i = 0; i < 100; i++)
    v[i] = rand();
  quickSort(v);
  vector<int>::iterator itr = v.begin();
  while (itr != v.end ()) {
    cout << *itr << " ";
    itr++;
  }
  cout << "\n";
}
