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
// File: linkedlist.cpp
// 
// Description: Simple templated linked list class
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <fstream>

using namespace std;

template <class item> int PartitionInPlace(item array[], int left, int key, int right);


template <class item> inline void Swap(item &a, item &b)
{
item tmp;

tmp=a;
a=b;
b=tmp;
}


template <class item> item SelectElement(item *array, int left, int right, int k)
{
int e,key;

if(right > left) 
  {// Uniform random key
	key=left+(rand()%(right-left+1)); 
	e=PartitionInPlace(array,left,key,right);
	
	// Recursion
	if (k<=e) return SelectElement(array,left,e,k);
	else
		SelectElement(array,e+1,right,k);
  }
	else // right=left
		return array[left];
}


#define N 20000
template <class item> void QuickSortRandom(item array[], int n);


int _tmain(int argc, _TCHAR* argv[])
{
	int *array, *arrays;
	int kth,k;

	
cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


	cout<<"Randomized Algorithm: Select"<<endl;


	array=new int[N];
	arrays=new int[N];

	for(int i=0;i<N;i++) {array[i]=rand();arrays[i]=array[i];}

	for(int round=0;round<30;round++)
	{

	k=1+(rand()%(N-1));
kth=SelectElement(array,0,N-1,k-1);

cout <<"The "<<k<<"th smallest element is "<<kth<<endl;

QuickSortRandom(arrays,N);


cout <<"I check that "<<kth<<" = " << arrays[k-1]<<endl;


char line[256];
cout<<"Press Return key"<<endl;
gets(line);
	}


delete [] array;
delete [] arrays;

cout<<"Press a key + <Return>"<<endl;
char toto;cin>>toto;


	return 0;
}


template <class item> int PartitionInPlace(item array[], int left, int key, int right)
{
item pivot;
int i,j;

Swap(array[right],array[key]);
pivot = array[right]; 
i = left-1; 
j = right;
    for(;;) 
	  {
      while(array[++i] < pivot);
      while(array[--j] > pivot);
      if(i >= j) break;
      Swap(array[i], array[j]);
	  }
    Swap(array[i],array[right]);

return i;
}

template <class item> void QuickSort(item array[], int left, int right)
{
  int e,key;

  if(right > left) 
  {
	// Uniform random key
	key=left+(rand()%(right-left+1)); 
	e= PartitionInPlace(array,left,key,right);

	// Recursive calls
    QuickSort(array,left,e-1);
    QuickSort(array,e+1,right);
  }
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


template <class item> void QuickSortRandom(item a[], int n)
{
RandomPermutation(a,n);
QuickSort(a,0,n-1);
}
