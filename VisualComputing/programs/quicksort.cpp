// ------------------------------------------------------------------------
// This program is complementary material for the book:
//
// Frank Nielsen
//
// Visual Computing: Geometry, Graphics, and Vision
//
// ISBN: 1-58450-427-7
//
// Charles River Media, Inc.
//
//
// All programs are available at http://www.charlesriver.com/visualcomputing/
//
// You may use this program for ACADEMIC and PERSONAL purposes ONLY. 
//
//
// The use of this program in a commercial product requires EXPLICITLY
// written permission from the author. The author is NOT responsible or 
// liable for damage or loss that may be caused by the use of this program. 
//
// Copyright (c) 2005. Frank Nielsen. All rights reserved.
// ------------------------------------------------------------------------
 
// ------------------------------------------------------------------------
// File: quicksort.cpp
// 
// Description: Randomized Quicksort for sorting an array of elements.
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <fstream>

using namespace std;

//
// Add template and overload > < =
// Hoare, C. A. R. "Partition: Algorithm 63," "Quicksort: Algorithm 64," and "Find: Algorithm 65." Comm. ACM 4, 321-322, 1961 
//

template <class item> inline void Swap(item &a, item &b)
{
item tmp;

tmp=a;
a=b;
b=tmp;
}


template <class item> void RandomPermutation(item array[], int n)
{
	int i,j;
	item tmp;

	for(i=1;i<n;i++)
	{
	j=rand()%i; // uniform random integer from 0 to i (included)
	Swap(array[i],array[j]);
	}
}



//
// Avg. nlog n time but  worst-case quadratic
//
template <class item> void QuickSortDet(item a[], int l, int r)
{
  item m;
  int j;
  int i;

  if(r > l) {
    
    m = a[r]; i = l-1; j = r;
    for(;;) {
      while(a[++i] < m);
      while(a[--j] > m);
      if(i >= j) break;
      Swap(a[i], a[j]);
    }
    Swap(a[i],a[r]);
    QuickSort(a,l,i-1);
    QuickSort(a,i+1,r);
  }
}

template <class item> void QuickSort(item array[], int left, int right)
{
  item pivot;
  int i,j,key;

  if(right > left) 
  {
	// Uniform random key
	key=left+(rand()%(right-left+1)); 
	Swap(array[right],array[key]);
    pivot = array[right]; 
	
	// Partition in place the array
	i = left-1; j = right;
    for(;;) 
	  {
      while(array[++i] < pivot);
      while(array[--j] > pivot);
      if(i >= j) break;
      Swap(array[i], array[j]);
	  }
    Swap(array[i],array[right]);

	// Recursive calls
    QuickSort(array,left,i-1);
    QuickSort(array,i+1,right);
  }
}

template <class item> void QuickSortRandom(item a[], int n)
{
RandomPermutation(a,n);
QuickSort(a,0,n-1);
}


#define N 100



int _tmain(int argc, _TCHAR* argv[])
{
int *array;


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


	cout<<"Randomized Algorithm QuickSort"<<endl;



	array=new int[N];
for(int i=0;i<N;i++) array[i]=rand();

QuickSortRandom(array,N);

for(int i=0;i<N-1;i++) 
{
	cout<<array[i]<<" ";
if (array[i]>array[i+1]) cerr<<"Error!"<<endl;
}
delete [] array;



char line[256];
cout<<"Press Return key"<<endl;
gets(line);

return 0;
}

