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
// File: traits-numerics.cpp
// 
// Description: Traits class concept using the numerics class in C++
// ------------------------------------------------------------------------


#include "stdafx.h"
#include <limits>


using namespace std;

template<class T> T MaxArray(const T* array, int n)
{
    // Initialize the maximum value to the minimum value
    // supported by class T
    T largest = numeric_limits<T>::min();

    for (int i=0; i < n; ++i)
        if (array[i] > largest) largest=array[i];

    return largest;
}


#define N 10

inline double drand()
{return rand()/(double)RAND_MAX;}

int _tmain(int argc, _TCHAR* argv[])
{
double arrayd[N];
int arrayi[N];
int i;


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


srand(2005); 

cout <<"Traits class: numerical constants in class numeric_limits."<<endl;

cout<<"First I create integer and double arrays."<<endl;
for(i=0;i<N;i++)
	{
	arrayd[i]=drand();
	arrayi[i]=rand();
	}

	cout<<"Array[double]:";
	for(i=0;i<N;i++)
	cout<<arrayd[i]<<" ";
	cout<<endl;

	cout<<"\nArray[int]:";
	for(i=0;i<N;i++)
	cout<<arrayi[i]<<" ";
	cout<<endl;


	cout<<"\nNow I call the MaxArray procedure using the traits class numerics."<<endl;
	cout<<"\n\nMax element of a double array:"<<MaxArray(arrayd,N)<<endl;
	cout<<"Max element of an integer array:"<<MaxArray(arrayi,N)<<endl;


	char line[256];
	cout<<"Press Return key"<<endl;
	gets(line);

	return 0;
}

